module Eaco

  # An Eaco Runtime Error.
  #
  class Error < StandardError
    # As we make use of heredoc for long error messages, squeeze subsequent
    # spaces and remove newlines.
    #
    def initialize(message)
      unless message =~ %r{EACO.+Error}
        message = message.squeeze(' ').gsub("\n", '')
      end

      super message
    end
  end

  # Raised when an Actor attempts an unauthorized access to a controller
  # action that deals with a protected Resource.
  #
  class Forbidden < Error; end

  # Represents a configuration error of the Eaco framework, whether wrong
  # options or wrong usage of the DSL, or invalid storage options for the
  # ACL objects and authorized collection extraction strategy.
  #
  class Malformed < Error; end

end
