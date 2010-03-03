# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  %w{ calendar_date_select chronic searchlogic daemons authlogic
      spreadsheet fastercsv formtastic will_paginate delayed_job
      validates_as_email_address }.each do |gem|
    config.gem gem
  end

  # :lib => false for gems that aren't needed during run time, not used often, or used for development only
  %w{ less whenever }.each do |gem|
    config.gem gem, :lib => false
  end

  # Some gems have different lib names compared to gem names
  config.gem 'mimetype-fu', :lib => 'mimetype_fu'

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