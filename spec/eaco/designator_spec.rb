# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'eaco/designator'

RSpec.describe Eaco::Designator do

  # TODO: auto-generated
  describe '#make' do
    it 'works' do
      value = double('value')
      instance = double('instance')
      designator = Eaco::Designator.new(value, instance)
      type = double('type')
      value = double('value')
      result = designator.make(type, value)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parse' do
    it 'works' do
      value = double('value')
      instance = double('instance')
      designator = Eaco::Designator.new(value, instance)
      string = double('string')
      result = designator.parse(string)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#resolve' do
    it 'works' do
      value = double('value')
      instance = double('instance')
      designator = Eaco::Designator.new(value, instance)
      designators = double('designators')
      result = designator.resolve(designators)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#configure!' do
    it 'works' do
      value = double('value')
      instance = double('instance')
      designator = Eaco::Designator.new(value, instance)
      options = double('options')
      result = designator.configure!(options)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#harvest' do
    it 'works' do
      value = double('value')
      instance = double('instance')
      designator = Eaco::Designator.new(value, instance)
      actor = double('actor')
      result = designator.harvest(actor)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#label' do
    it 'works' do
      value = double('value')
      instance = double('instance')
      designator = Eaco::Designator.new(value, instance)
      value = double('value')
      result = designator.label(value)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#id' do
    it 'works' do
      value = double('value')
      instance = double('instance')
      designator = Eaco::Designator.new(value, instance)
      result = designator.id
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#search' do
    it 'works' do
      value = double('value')
      instance = double('instance')
      designator = Eaco::Designator.new(value, instance)
      query = double('query')
      result = designator.search(query)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#new' do
    it 'works' do
      value = double('value')
      instance = double('instance')
      result = Eaco::Designator.new(value, instance)
      expect(result).not_to be_nil
    end
  end

end
