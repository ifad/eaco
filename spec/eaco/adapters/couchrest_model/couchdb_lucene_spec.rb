# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'eaco/adapters/couchrest_model/couchdb_lucene'

RSpec.describe Eaco::Adapters::CouchrestModel::CouchDBLucene do

  # TODO: auto-generated
  describe '#accessible_by' do
    it 'works' do
      couch_db_lucene = Eaco::Adapters::CouchrestModel::CouchDBLucene.new
      actor = double('actor')
      result = couch_db_lucene.accessible_by(actor)
      expect(result).not_to be_nil
    end
  end

end
