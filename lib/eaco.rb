require 'eaco/error'
require 'eaco/version'

if defined? Rails
  require 'eaco/railtie'
end

require 'pathname'

############################################################################
#
# Welcome to Eaco!
#
# Eaco is a full-fledged authorization framework for Ruby that allows you to
# describe which actions are allowed on your resources, how to identify your
# users as having a particular privilege and which privileges are granted to
# a specific resource through the usage of ACLs.
#
module Eaco
  autoload :ACL,        'eaco/acl'
  autoload :Actor,      'eaco/actor'
  autoload :Adapters,   'eaco/adapters'
  autoload :DSL,        'eaco/dsl'
  autoload :Designator, 'eaco/designator'
  autoload :Resource,   'eaco/resource'

  ##
  # Parses and evaluates the authorization rules from
  #
  #   ./config/authorization.rb
  #
  # The authorization rules define all the authorization framework behaviour
  # through a DSL. Please see +Eaco::DSL+ and below for details.
  #
  # @return true
  # @raise  Eaco::Error if an error occurs during parsing.
  #
  def self.parse_default_rules_file!
    rules = Pathname('./config/authorization.rb')

    unless rules.exist?
      raise Malformed, "Please create #{rules.realpath} with Eaco authorization rules"
    end

    eval! rules.read, rules.realpath.to_s
  end

  ##
  # Evaluates the given authorization rules +source+, orignally found on
  # +path+.
  #
  # @param source [String] {DSL} source code
  # @param path [String] Source code origin, for better backtraces.
  #
  # @return true
  #
  # @raise [Error] if something goes wrong while evaluating the DSL.
  #
  # @see DSL
  #
  def self.eval!(source, path)
    DSL.send :eval, source, nil, path, 1

    true
  rescue => e
    raise Error, <<-EOF

=== EACO === Error while evaluating rules

#{e.message}

 +--------- -- -
 | #{e.backtrace.join("\n | ")}
 +-

=== EACO ===

    EOF
  end

end
