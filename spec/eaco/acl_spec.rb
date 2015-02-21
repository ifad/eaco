# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'eaco/acl'

RSpec.describe Eaco::ACL do

  # TODO: auto-generated
  describe '#new' do
    it 'works' do
      definition = double('definition')
      result = Eaco::ACL.new(definition)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add' do
    it 'works' do
      definition = double('definition')
      acl = Eaco::ACL.new(definition)
      role = double('role')
      *designator = double('*designator')
      result = acl.add(role, *designator)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#del' do
    it 'works' do
      definition = double('definition')
      acl = Eaco::ACL.new(definition)
      *designator = double('*designator')
      result = acl.del(*designator)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#find_by_role' do
    it 'works' do
      definition = double('definition')
      acl = Eaco::ACL.new(definition)
      name = double('name')
      result = acl.find_by_role(name)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#all' do
    it 'works' do
      definition = double('definition')
      acl = Eaco::ACL.new(definition)
      result = acl.all
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#designators_map_for_role' do
    it 'works' do
      definition = double('definition')
      acl = Eaco::ACL.new(definition)
      name = double('name')
      result = acl.designators_map_for_role(name)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#actors_by_role' do
    it 'works' do
      definition = double('definition')
      acl = Eaco::ACL.new(definition)
      name = double('name')
      result = acl.actors_by_role(name)
      expect(result).not_to be_nil
    end
  end

end
