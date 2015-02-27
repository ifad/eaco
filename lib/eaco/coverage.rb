require 'coveralls'

module Eaco

  ##
  # Integration with code coverage tools.
  #
  # Loading this module will start collecting coverage data.
  #
  module Coverage
    Coveralls.wear_merged!

    ##
    # Reports coverage data to the remote service
    #
    # @return [nil]
    #
    def self.report!
      Coveralls.push!

      nil
    end
  end

end
