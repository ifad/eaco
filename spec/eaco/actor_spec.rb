# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'eaco/actor'

RSpec.describe Eaco::Actor do

  # TODO: auto-generated
  describe '#designators' do
    it 'works' do
      actor = Eaco::Actor.new
      result = actor.designators
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#is_admin?' do
    it 'works' do
      actor = Eaco::Actor.new
      result = actor.is_admin?
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#can?' do
    it 'works' do
      actor = Eaco::Actor.new
      action = double('action')
      target = double('target')
      result = actor.can?(action, target)
      expect(result).not_to be_nil
    end
  end

end
