module Eaco
  module Cucumber
    module ActiveRecord

      # @!method schema
      #
      # Defines the database schema for the {Eaco::Cucumber::World} scenario.
      #
      # @see Eaco::Cucumber::World
      #
      ::ActiveRecord::Schema.define(version: '2015022301') do
        create_table 'documents', force: true do |t|
          t.string :name
          t.text   :contents
          t.column :acl, :jsonb
        end

        create_table 'users', force: true do |t|
          t.string :name
        end

        create_table 'departments', force: true do |t|
          t.string :abbr
        end

        create_table 'positions', force: true do |t|
          t.string :job_title

          t.references :user
          t.references :department
        end
      end

    end
  end
end
