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

  # The location of the default rules file
  DEFAULT_RULES = Pathname('./config/authorization.rb')

  ##
  # Parses and evaluates the authorization rules from the {DEFAULT_RULES}.
  #
  # The authorization rules define all the authorization framework behaviour
  # through the {DSL}
  #
  # @return (see .eval!)
  #
  def self.parse_default_rules_file!
    parse_rules! DEFAULT_RULES
  end

  ##
  # Parses the given +rules+ file.
  #
  # @param rules [Pathname]
  #
  # @return (see .eval!)
  #
  # @raise [Malformed] if the +rules+ file does not exist.
  #
  def self.parse_rules!(rules)
    unless rules.exist?
      path = rules.realpath rescue rules.to_s
      raise Malformed, "Please create #{path} with Eaco authorization rules"
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
