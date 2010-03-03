config.cache_classes                                 = true
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true
config.action_controller.allow_forgery_protection    = false
config.whiny_nils                                    = true
config.action_mailer.delivery_method                 = :test
# config.action_mailer.raise_delivery_errors           = false
# config.action_view.debug_rjs                         = true

# dependancies
config.gem 'email_spec'
%w{ term-ansicolor treetop diff-lcs nokogiri
    builder factory_girl ruby-terminfo }.each do |gem|
  config.gem gem, :lib => false
end

config.gem 'cucumber-rails',   :lib => false, :version => '>=0.2.4' unless File.directory?(File.join(Rails.root, 'vendor/plugins/cucumber-rails'))
config.gem 'database_cleaner', :lib => false, :version => '>=0.4.3' unless File.directory?(File.join(Rails.root, 'vendor/plugins/database_cleaner'))
config.gem 'webrat',           :lib => false, :version => '>=0.6.0' unless File.directory?(File.join(Rails.root, 'vendor/plugins/webrat'))
config.gem 'rspec',            :lib => false, :version => '>=1.3.0' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec'))
config.gem 'rspec-rails',      :lib => false, :version => '>=1.3.2' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
