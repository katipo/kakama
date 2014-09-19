Kakama::Application.configure do
  config.cache_classes                                 = true
  config.action_controller.consider_all_requests_local = false
  config.action_controller.perform_caching             = true

  if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
    warn "WARNING: Enable config.action_view.cache_template_loading for use in Rail >= 3.1"
  end
  #config.action_view.cache_template_loading            = true

# config.action_controller.allow_forgery_protection    = false
# config.whiny_nils                                    = true
# config.action_mailer.delivery_method                 = :test
  config.action_mailer.raise_delivery_errors           = false
# config.action_view.debug_rjs                         = true

# Rails enables starttls when on Ruby 1.8.7, which doesn't always work
# So instead, make a copy of Rails default settings, turning tls off
  config.action_mailer.smtp_settings = {
      :address              => "localhost",
      :port                 => 25,
      :domain               => 'localhost.localdomain',
      :enable_starttls_auto => false
  }
end
