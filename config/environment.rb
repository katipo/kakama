# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.9' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
config.gem 'calendar_date_select', :version => '1.16.1'
config.gem 'authlogic', :version => '2.1.3'
config.gem 'actionpack', :version => '2.3.9' #Dependency of formtastic
config.gem 'formtastic', :version => '1.1.0'
config.gem 'will_paginate', :version => '2.3.12'
config.gem 'faker', :version => '0.3.1', :lib => false
config.gem 'ruby-progressbar', :version => '0.0.10', :lib => false
config.gem 'factory_girl', :version => '1.3.3'
config.gem 'chronic', :version => '0.2.3'
config.gem 'whenever', :version => '0.4.2'
config.gem 'ruby-prof', :version => '0.7.3', :lib => false
config.gem 'rcov', :version => '1.0.0', :lib => false
config.gem 'searchlogic', :version => '2.4.19'

config.gem 'chronic', :version => '0.2.3'
config.gem 'daemons', :version '1.0.10'

#Cucumber and dependencies
config.gem 'cucumber', :version => '0.6.4', :lib => false
config.gem 'email_spec', :version => '0.6.2', :lib => false
config.gem 'timecop', :version => '0.3.4', :lib => false
config.gem 'nokogiri', :version => '1.4.1', :lib => false
config.gem 'ruby-terminfo', :version => '0.1.1', :lib => false
config.gem 'cucumber-rails', :version => '0.3.0', :lib => false
config.gem 'database_cleaner', :version => '0.5.0', :lib => false
config.gem 'webrat', :version => '0.7.3', :lib => false
config.gem 'rspec', :version => '1.3.2', :lib => false
config.gem 'rspec-rails', :version => '1.3.2', :lib => false

%w{ spreadsheet fastercsv
      validates_as_email_address }.each do |gem|
    config.gem gem
  end

  # :lib => false for gems that aren't needed during run time, not used often, or used for development only
  %w{ less whenever }.each do |gem|
    config.gem gem, :lib => false
  end

  # Some gems have different lib names compared to gem names
  config.gem 'mimetype-fu', :lib => 'mimetype_fu'

  # The API for DelayedJob has changed, so rely on a set version until we can upgrade
  config.gem 'delayed_job', :version => '1.8.5'

  # The API for Prawn is constantly changing, so rely on set versions for some gems we know work
  config.gem 'prawn', :version => '0.7.2'
  config.gem 'prawn-layout', :lib => 'prawn/layout', :version => '0.7.2'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Paris'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end