config.cache_classes                                 = false
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = false
# config.action_controller.allow_forgery_protection    = false
config.whiny_nils                                    = true
# config.action_mailer.delivery_method                 = :test
config.action_mailer.raise_delivery_errors           = false
config.action_view.debug_rjs                         = true

# Rails enables starttls when on Ruby 1.8.7, which doesn't always work
# So instead, make a copy of Rails default settings, turning tls off
config.action_mailer.smtp_settings = {
  :address              => "localhost",
  :port                 => 25,
  :domain               => 'localhost.localdomain',
  :enable_starttls_auto => false
}
