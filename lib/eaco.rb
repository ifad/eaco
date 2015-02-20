if defined? Rails
  require 'eaco/railtie'
end

require 'pathname'

module Eaco

  class Error < StandardError; end
  class Forbidden < Error; end
  class Malformed < Error; end

  autoload :ACL, 'eaco/acl'
  autoload :Adapters, 'eaco/adapters'
  autoload :DSL, 'eaco/dsl'
  autoload :Designator, 'eaco/designator'
  autoload :VERSION, 'eaco/version'

  # Parses and evaluates authorization rules
  #
  def self.parse!
    rules = Pathname('./config/authorization.rb')

    unless rules.exist?
      raise Error, "Please create #{rules.realpath} with authorization rules"
    end

    DSL.send :eval, rules.read, nil, rules.realpath.to_s, 1

  rescue => e
    raise Error, "Error while parsing authorization rules: #{e.message}\n\n#{e.backtrace.join("\n  ")}"
  end

end
