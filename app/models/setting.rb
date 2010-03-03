class Setting
  Data = {
    :site_name => {
      :default_value => 'Kakama Scheduling System',
      :description => 'Displayed in the header of all webpages, pdfs, and emails.'
    },
    :site_url => {
      :default_value => 'http://localhost:3000',
      :description => 'This URL will be sent in pdfs and emails (no trailing slash).'
    },
    :site_description => {
      :default_value => '',
      :description => 'Displayed under the site name in the header. Leave blank for no description.'
    },
    :session_timeout => {
      :default_value => 15,
      :description => 'Inactivity in minutes before a user is automatically logged out (set to 0 for no session timeout).'
    },
    :notifier_email => {
      :default_value => 'no-reply@company.com',
      :description => 'Emails sent out will be from this email. Usually want something like no-reply@company.com.'
    },
    :site_administrator_emails => {
      :default_value => ['admin@changeme.com'],
      :description => "Notifications of event rosterings will be sent to these email addresses. e.g. ['test@test.com', 'example@example.com']"
    },
    :character_set => {
      :default_value => 'utf-8',
      :description => 'What character set are we using for displaying pages?'
    },
    :company_name => {
      :default_value => 'Annonymous Inc.',
      :description => 'The name of the company running this Kakama application.'
    },
    :company_url => {
      :default_value => 'http://example.com',
      :description => 'A link back to the company website running this Kakama application.'
    },
    :full_names_in_mails_headers => {
      :default_value => true,
      :description => 'Should full names be used in mail headers? Will use username only instead if false.'
    },
    :event_cut_off => {
      :default_value => 3,
      :description => 'How many days before the event is the event cut off, and things finalized?'
    },
    :response_time => {
      :default_value => 5,
      :description => 'How many days after getting the event rostering email should staff be given to respond?'
    },
    :administrators_can_be_rostered => {
      :default_value => false,
      :description => 'Can site admins be rostered to events like regular staff members?'
    },
    :administrators_get_special_emails => {
      :default_value => true,
      :description => 'Should site administrators get a copy of special emails sent from the system (site wide, staff rostered, staff member, and delivery notifications)?'
    },
    :attachment_limit => {
      :default => false,
      :description => 'How many attachments should be sent in a single email? (false for unlimited, or a number)'
    }
  }

  @@settings = Hash.new
  # Quickly populate default values. Some may be overwritten later
  Data.each { |key, values| @@settings[key.to_s] = values[:default_value] }

  @@settings_file = File.join(Rails.root, 'config', 'settings.yml')
  @@settings.merge!(YAML.load(IO.read(@@settings_file))) if File.exists?(@@settings_file)

  # Small hack to be able to overwrite settings in test mode, so test mode doesn't
  # rely on developers having the absolute correct values during development
  if %w{ test cucumber }.include?(Rails.env)
    test_settings_file = File.join(Rails.root, 'test', 'settings.yml')
    @@settings.merge!(YAML.load(IO.read(test_settings_file))) if File.exists?(test_settings_file)
  end

  def self.site_host
    return unless @@settings['site_url']
    @@settings['site_url'].gsub('http://', '')
  end

  def self.notifier_email_with_name
    "#{@@settings['site_name']} <#{@@settings['notifier_email']}>"
  end

  def self.all
    @@settings
  end

  # Update the settings. If save is false, it won't store the settings, making them only applicable for the
  # current initialization of the app (each request in dev/test, or on app startup in production)
  def self.update(hash, save = true)
    @@settings = @@settings.merge(hash.stringify_keys)

    # Convert numbers in strings from strings to integers
    # Convert boolean in strings from strings to booleans
    @@settings.each do |k, v|
      v = eval(v) if !v.blank? && v.is_a?(String) && v.strip =~ /^([0-9\{\[]|true|false)/
      @@settings[k] = v
    end

    # save yaml
    if save
      File.open(@@settings_file, "w") do |file|
        file.puts @@settings.to_yaml
      end
    end

    @@settings
  end

  private

  def self.method_missing( method_sym, *args, &block )
    if @@settings.key?(method_sym.to_s)
      @@settings[method_sym.to_s]
    else
      super
    end
  end

end
