begin
  require 'less'
rescue LoadError => e
  e.message << " (You may need to install the less gem)"
  raise e
end

require File.join(File.dirname(__FILE__), 'lib', 'more')

case Rails.env
when "development"
  ActionController::Base.before_filter {
    Less::More.clean
    Less::More.parse unless Less::More.heroku?
  }
else
  config.after_initialize {
    Less::More.clean
    Less::More.parse unless Less::More.heroku?
  }
end
