# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'eaco/adapters/active_record/postgres_jsonb'

RSpec.describe Eaco::Adapters::ActiveRecord::PostgresJSONb do

  # TODO: auto-generated
  describe '#accessible_by' do
    it 'works' do
      postgres_jso_nb = Eaco::Adapters::ActiveRecord::PostgresJSONb.new
      actor = double('actor')
      result = postgres_jso_nb.accessible_by(actor)
      expect(result).not_to be_nil
    end
  end

end
