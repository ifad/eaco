# Boot Active Record on the upgrade target (Ruby 4 / Rails 8.1) and exercise
# eaco's load-bearing path: the AR compatibility layer that USED to raise
# "Unsupported Active Record version" on anything past 6.1, plus an end-to-end
# in-memory authorization check (ACL grant -> Actor#can?).
#
# No PostgreSQL: the pg_jsonb adapter only needs a json/jsonb `acl` column to
# install, which sqlite's :json type satisfies. We assert the authorization
# decision (in-memory ACL eval), not the pg-specific accessible_by SQL.
$stdout.sync = true
require 'logger'
require 'active_record'
require 'eaco'

# Reuse the gem's own example Actor/Resource/Designator fixtures.
require 'eaco/cucumber/active_record/document'
require 'eaco/cucumber/active_record/user'

AR   = Eaco::Cucumber::ActiveRecord
User = AR::User
Doc  = AR::Document

$failed = false
def check(label)
  yield
  puts "[ok] #{label}"
rescue => e
  puts "[FAIL] #{label}: #{e.class}: #{e.message}"
  puts e.backtrace.first(6).map { |l| "      #{l}" }
  $failed = true
end

ActiveRecord::Base.logger = Logger.new(IO::NULL)
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :documents do |t|
    t.string :name
    t.json   :acl          # sqlite :json satisfies the adapter's column check
  end
  create_table :users do |t|
    t.string  :name
    t.boolean :admin, default: false
  end
end

puts "stack: ruby #{RUBY_VERSION} / Active Record #{ActiveRecord::VERSION::STRING}"

# 1. THE blocker: installing the pg_jsonb adapter runs Compatibility#check!,
#    which raised on AR > 6.1 before this upgrade. Configure via the real DSL.
check "eaco authorization DSL installs on Active Record #{ActiveRecord::VERSION::MAJOR}" do
  Eaco.eval! <<~DSL, '(smoke)'
    actor #{User} do
      admin do |user|
        user.admin?
      end

      designators do
        authenticated from: :class
        user          from: :id
      end
    end

    authorize #{Doc}, using: :pg_jsonb do
      roles :writer, :reader

      permissions do
        reader :read
        writer reader, :write
      end
    end
  DSL

  raise "Document not a Resource" unless Doc.include?(Eaco::Resource)
  raise "User not an Actor"       unless User.include?(Eaco::Actor)
end

# 2. End-to-end authorization decision (in-memory ACL eval, no pg query).
check "ACL grant + Actor#can? resolves the right permissions" do
  granted = User.new(id: 1, name: 'Granted')
  other   = User.new(id: 2, name: 'Other')

  doc = Doc.new(name: 'Spec')
  doc.acl = Doc.acl.new.tap { |acl| acl.add(:reader, :user, 1) }

  raise "granted user cannot read"     unless granted.can?(:read,  doc)
  raise "reader unexpectedly can write" if     granted.can?(:write, doc)
  raise "ungranted user can read"       if     other.can?(:read,   doc)
end

# 3. Admin bypass (admin_logic short-circuits to allow).
check "admin actor is allowed regardless of ACL" do
  admin = User.new(id: 3, name: 'Boss', admin: true)
  doc   = Doc.new(name: 'Locked')   # empty ACL
  raise "admin denied" unless admin.can?(:write, doc)
end

if $failed
  puts "\nSMOKE FAILED"
  exit 1
else
  puts "\nSMOKE OK — eaco authorizes on Ruby #{RUBY_VERSION} / " \
       "Active Record #{ActiveRecord::VERSION::STRING}"
end
