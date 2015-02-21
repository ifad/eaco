# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'eaco/error'

RSpec.describe Eaco::Error do

  # TODO: auto-generated
  describe '#new' do
    it 'works' do
      message = double('message')
      result = Eaco::Error.new(message)
      expect(result).not_to be_nil
    end
  end

end
