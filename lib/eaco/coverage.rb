require 'coveralls'
require 'simplecov'

module Eaco

  ##
  # Integration with code coverage tools.
  #
  # Loading this module will start collecting coverage data.
  #
  module Coverage
    extend self

    ##
    # Starts collecting coverage data.
    #
    # @return [nil]
    #
    def start!
      Coveralls.wear_merged!

      nil
    end

    ##
    # Reports coverage data to the remote service
    #
    # @return [nil]
    #
    def report!
      Coveralls.push!

      nil
    end

    ##
    # @return [Fixnum] the percentage of the code covered by tests
    #
    def percent
      SimpleCov.result && SimpleCov.result.covered_percent
    end
  end

end
