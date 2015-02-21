# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'eaco/controller'

RSpec.describe Eaco::Controller::ClassMethods do

  # TODO: auto-generated
  describe '#authorize' do
    it 'works' do
      class_methods = Eaco::Controller::ClassMethods.new
      *actions = double('*actions')
      result = class_methods.authorize(*actions)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#permission_for' do
    it 'works' do
      class_methods = Eaco::Controller::ClassMethods.new
      action = double('action')
      result = class_methods.permission_for(action)
      expect(result).not_to be_nil
    end
  end

end
