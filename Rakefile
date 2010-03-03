# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

#require 'yard'
#YARD::Rake::YardocTask.new do |t|
#  t.files   = ['app/**/*.rb', 'lib/**/*.rb']
#  t.options = ['--protected', '--private', '--readme=README.rdoc']
#end

# Rake tasks for DelayedJob
begin
  require 'delayed/tasks'
rescue LoadError
  STDERR.puts "Run `rake gems:install` to install delayed_job"
end
