# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'eaco/adapters/active_record'

RSpec.describe Eaco::Adapters::ActiveRecord do

  # TODO: auto-generated
  describe '#included' do
    it 'works' do
      base = double('base')
      result = Eaco::Adapters::ActiveRecord.included(base)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#acl' do
    it 'works' do
      active_record = Eaco::Adapters::ActiveRecord.new
      result = active_record.acl
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#acl=' do
    it 'works' do
      active_record = Eaco::Adapters::ActiveRecord.new
      acl = double('acl')
      result = active_record.acl=(acl)
      expect(result).not_to be_nil
    end
  end

end
