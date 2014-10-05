Kakama::Application.configure do
  config.cache_classes                                 = true
  config.action_controller.consider_all_requests_local = false
  config.action_controller.perform_caching             = true

  if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
    warn "WARNING: Enable config.action_view.cache_template_loading for use in Rail >= 3.1"
  end

  #config.action_view.cache_template_loading            = true
  config.action_controller.allow_forgery_protection    = false
  config.whiny_nils                                    = true
  config.action_mailer.delivery_method                 = :test
# config.action_mailer.raise_delivery_errors           = false
end

