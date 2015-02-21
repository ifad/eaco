# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'eaco/dsl/resource'

RSpec.describe Eaco::DSL::Resource do

  # TODO: auto-generated
  describe '#new' do
    it 'works' do
      target = double('target')
      result = Eaco::DSL::Resource.new(target)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#permissions' do
    it 'works' do
      target = double('target')
      resource = Eaco::DSL::Resource.new(target)
      result = resource.permissions
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#roles' do
    it 'works' do
      target = double('target')
      resource = Eaco::DSL::Resource.new(target)
      result = resource.roles
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#roles_priority' do
    it 'works' do
      target = double('target')
      resource = Eaco::DSL::Resource.new(target)
      result = resource.roles_priority
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#roles_with_labels' do
    it 'works' do
      target = double('target')
      resource = Eaco::DSL::Resource.new(target)
      result = resource.roles_with_labels
      expect(result).not_to be_nil
    end
  end

end
