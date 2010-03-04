# email testing in cucumber
require 'email_spec/cucumber'

# factories
require File.expand_path(File.dirname(__FILE__) + '/../../test/factories')

require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'tasks/rails'
silence_stream(STDOUT) do
  Rake::Task['db:reset'].execute(ENV)
  Rake::Task["db:seed_fu"].execute(ENV)
end

# After each test, return Time to
# the present incase we forgot to
After do
  Timecop.return
end
