require 'eaco/error'
require 'eaco/version'

if defined? Rails
  require 'eaco/railtie'
end

require 'pathname'

# Welcome to Eaco!
#
module Eaco
  autoload :ACL,        'eaco/acl'
  autoload :Actor,      'eaco/actor'
  autoload :Adapters,   'eaco/adapters'
  autoload :DSL,        'eaco/dsl'
  autoload :Designator, 'eaco/designator'
  autoload :Resource,   'eaco/resource'

  # Parses and evaluates the authorization rules, looking them up into
  # './config/authorization.rb'.
  #
  def self.parse!
    rules = Pathname('./config/authorization.rb')

    unless rules.exist?
      raise Malformed, "Please create #{rules.realpath} with authorization rules"
    end

    DSL.send :eval, rules.read, nil, rules.realpath.to_s, 1

  rescue => e
    raise Error, "\n\n=== EACO === Error while parsing authorization rules: #{e.message}\n\n  #{e.backtrace.join("\n  ")}\n\n=== EACO ===\n\n"
  end

end
