# frozen_string_literal: true

module Eaco

  ##
  # Namespace to all rake-related functionality.
  #
  module Rake
    autoload :Utils,       'eaco/rake/utils.rb'
    autoload :DefaultTask, 'eaco/rake/default_task.rb'
  end

end