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
config.gem "calendar_date_select", :version => '1.16.1'
config.gem 'authlogic', :version => '2.1.3'
config.gem 'actionpack', :version => '2.3.5' #Dependency of formtastic 0.9.8
config.gem 'formtastic', :version => '0.9.8'
config.gem 'will_paginate', :version => '2.3.12'
config.gem 'faker', :version => '0.3.1', :lib => false
config.gem 'progressbar', :version => '0.9.0', :lib => false
config.gem 'factory_girl', :version => '1.2.4'

  %w{ chronic searchlogic daemons
      spreadsheet fastercsv
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
  config.time_zone = 'Wellington'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end