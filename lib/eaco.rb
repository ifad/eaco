require 'eaco/version'
require 'eaco/acl'
require 'eaco/controller'
require 'eaco/designator'
require 'eaco/dsl'

require 'pathname'

module Eaco

  class Error < StandardError; end
  class Forbidden < Error; end
  class Malformed < Error; end

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
