Kakama::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
    warn "WARNING: Enable config.action_view.cache_template_loading for use in Rail >= 3.1"
  end

  #config.action_view.cache_template_loading            = false

  # config.action_controller.allow_forgery_protection    = false
  config.whiny_nils                                    = true
  # config.action_mailer.delivery_method                 = :test

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Rails enables starttls when on Ruby 1.8.7, which doesn't always work
  # So instead, make a copy of Rails default settings, turning tls off
  config.action_mailer.smtp_settings = {
      :address              => "localhost",
      :port                 => 25,
      :domain               => 'localhost.localdomain',
      :enable_starttls_auto => false
  }

  # Expands the lines which load the assets
  # config.assets.debug = true

  # config.assets.compress = false

  # Use rails 3 asset pipeline to compress css and js
  # config.assets.css_compressor = :yui
  # config.assets.js_compressor = :uglify
end
