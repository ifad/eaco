# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'eaco/dsl/actor'

RSpec.describe Eaco::DSL::Actor do

  # TODO: auto-generated
  describe '#new' do
    it 'works' do
      target = double('target')
      result = Eaco::DSL::Actor.new(target)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#designators' do
    it 'works' do
      target = double('target')
      actor = Eaco::DSL::Actor.new(target)
      result = actor.designators
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#admin_logic' do
    it 'works' do
      target = double('target')
      actor = Eaco::DSL::Actor.new(target)
      result = actor.admin_logic
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#find_designator' do
    it 'works' do
      target = double('*')
      actor = Eaco::DSL::Actor.new(target)
      name = double('name')
      result = actor.find_designator(name)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#register_designators' do
    it 'works' do
      target = double('target')
      actor = Eaco::DSL::Actor.new(target)
      new_designators = double('new_designators')
      result = actor.register_designators(new_designators)
      expect(result).not_to be_nil
    end
  end

end
