require 'database_cleaner'
require 'database_cleaner/cucumber'

DatabaseCleaner.strategy = :transaction

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
