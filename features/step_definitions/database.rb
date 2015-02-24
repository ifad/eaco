Given(/I am connected to the database/) do
  Eaco::Cucumber::ActiveRecord.connect!
end

Given(/I have a schema defined/) do
  Eaco::Cucumber::ActiveRecord.define_schema!
end
