class Notifier < ActionMailer::Base
  ActionMailer::Base.default_url_options[:host] = Setting.site_host
  ActionMailer::Base.default :content_type => "text/html"

  # Create a method that allows us to send emails if email exists,
  # otherwise send the PDF equivelent to the administrator for testing

  # If you need to add attachments, use the add_attachment(s) method
  # You don't need to use part() {} to add a message body because in ActionMailer
  # 3 and up the email parts are automatically generated, and the content_type
  # is set to multipart/mixed
  # See postage_delivery_required as an example

  # Which email types should admins be CC'd on?
  CC_TO_ADMIN = %w{ email_to_all_staff event_rosterings_contact
                    postage_delivery_required staff_email }

  # An array of mailing templates that are static (don't contain information spefic to a staff member)
  # These are used to decide if an email gets sent in mass via bcc, or one at a time (via to)
  STATIC_MAILERS = %w{ email_to_all_staff event_rosterings_contact }

  # Overwrite ActionMailers default initialize method to store @mailer_name
  # which we can then access later on
  def initialize(*parameters) #:nodoc:
    @mailer_name = parameters.first
    super
  end

  # Provide a way to send emails to users with email addresses, or email the pdfs to admins if the
  # recipient doesn't have an email address. For people with emails, send one email with their email
  # in the bcc field if the email type is static, i.e. dont references them specifically
  def self.deliver_email_or_pdf_of(type, recipients, *args)
    recipients_with_emails, recipients_without_emails = Array.new, Array.new
    pdf_generators, event = Array.new, args.find { |arg| arg.is_a?(Event) }

    # Determine which recipients have emails to send to,
    # and which need PDFs printed and mailed to them
    Array(recipients).each do |recipient|
      if recipient.is_a?(Staff) && recipient.email.blank?
        recipients_without_emails << recipient
      else
        recipients_with_emails << recipient
      end
    end

    # If this email type is static, send all recipients to it for
    # bulk emailing, rather than sending emails one by one
    if recipients_with_emails.size > 0
      if STATIC_MAILERS.include?(type.to_s)
        Notifier.send("#{type.to_s}", recipients_with_emails, *args).deliver
      else
        recipients_with_emails.each do |recipient|
          Notifier.send("#{type.to_s}", recipient, *args).deliver
        end
      end
    end

    # For the rest without emails, send pdfs to the site admins for mailing
    if recipients_without_emails.size > 0
      recipients_without_emails.each do |recipient|
        generator = PdfGenerator.send("create_#{type.to_s}", recipient, *args)
        generator.filename = "#{type.to_s}_for_#{recipient.username}.pdf"
        pdf_generators << generator.save
      end
      Notifier.collection_of_pdfs(pdf_generators, event).deliver
    end
  end

  def self.deliver_collection_of_pdfs(pdf_generators, *args)
    # incase admins get sent too many emails, provide an
    # option to limit attachment count in each email
    all_pdf_paths = pdf_generators.collect { |generator| generator.save_path }
    if Setting.attachment_limit && Setting.attachment_limit.to_i > 0
      all_pdf_paths.in_groups_of(Setting.attachment_limit.to_i, false).each do |pdf_paths|
        Notifier.postage_delivery_required(pdf_paths, *args).deliver
      end
    else
      Notifier.postage_delivery_required(all_pdf_paths, *args).deliver
    end

    pdf_generators.each { |generator| generator.delete! }
  end

  #
  # All mailer methods are sorted alphabetically according to the view file
  #

  def availability_changes_notification(recipient, availability)
    subject = if recipient.is_a?(Staff)
      'Your availability has been changed by an administrator'
    else
      "Availability of #{availability.staff.full_name} has been changed"
    end
    @availability = availability
    mail(setup_email_options('Availability Changes', subject, recipient))
  end

  def email_to_all_staff(recipients, email_subject, email_body)
    @email_subject = email_subject
    @email_body = email_body
    mail(setup_email_options('Site Wide email', 'An administrator has sent all staff members an email',
                { :to => Setting.notifier_email_with_name, :bcc => recipients }))
  end

  def event_cancelled_notification(recipient, event, role)
    @recipient = recipient
    @event = event
    @role = role
    mail(setup_email_options('Event Cancelled', "The event '#{event.name}' has been cancelled", recipient, event))
  end

  def event_name_change_notification(recipient, event, role, previous_name)
    @recipient = recipient
    @event = event
    @role = role
    @previous_name = previous_name
    mail(setup_email_options('Event Name Changed', "The event '#{previous_name}' has been renamed '#{event.name}'", recipient, event))
  end

  def event_rosterings_contact(recipients, event, email_subject, email_body)
    @event = event
    @email_subject = email_subject
    @email_body = email_body
    mail(setup_email_options( 'Event Rostering Contact', "An administrator has contacted you regarding the event '#{event.name}'",
                { :to => Setting.notifier_email_with_name, :bcc => recipients }, event))
  end

  def event_time_change_notification(recipient, event, role, is_available)
    @recipient = recipient
    @event = event
    @role = role
    @is_available = is_available
    mail(setup_email_options( 'Event Time Changed', "The event '#{event.name}' has had it's start or end times changed", recipient, event))
  end

  # events_and_roles looks like this:   { Event => Role, Event => Role }
  def multiple_rostering_created_notification(recipient, events_and_roles)
    @recipient = recipient
    @events_and_roles = events_and_roles
    mail(setup_email_options('Multiple Events Rostered to Staff',
                             'You have been scheduled to work at multiple new events',
                             recipient, events_and_roles.keys))
  end

  def password_reset_instructions(recipient)
    @perishable_token = recipient.perishable_token
    mail(setup_email_options('Password Reset Instructions',
                             'Instructions to reset your password', recipient))
  end

  def postage_delivery_required(attachment_paths, event = nil)
    recipient = event ? (event.approved? ? event.approver : event.organiser) : nil
    recipient = Setting.site_administrator_emails if recipient.nil? || recipient.email.blank?
    add_attachments(attachment_paths)

    # In ActionMailer 3.0 and up the mail method automatically generates
    # an email with a content_type of 'multipart/mixed' when you add attachments
    mail(setup_email_options('Postage Notification Required',
                             'Document printing and mail to staff required', recipient))
  end

  def rostering_cancelled_notification(recipient, event, role, reason='')
    @recipient = recipient
    @event = event
    @role = role
    @reason = reason
    mail(setup_email_options('Event Rostering Cancelled',
            "An administrator has cancelled your involvement at the event '#{event.name}'",
            recipient, event))
  end

  def rostering_confirmed_notification(recipient, event, role)
    @recipient = recipient
    @event = event
    @role = role
    mail(setup_email_options('Event Rostering Confirmed',
        "Confirmation of details for your new rostering at the event '#{event.name}'",
        recipient, event))
  end

  def rostering_created_notification(recipient, event, role)
    @recipient = recipient
    @event = event
    @role = role
    mail(setup_email_options('Event Rostered to Staff', 'You have been scheduled to work at a new event', recipient, event))
  end

  def staff_account_creation(recipient)
    @recipient = recipient
    mail(setup_email_options('Account Creation', 'An account has been created for you', recipient))
  end

  def staff_email(recipient, email_subject, email_body)
    @recipient = recipient
    @email_subject = email_subject
    @email_body = email_body
    mail(setup_email_options('Personal Email', 'An administrator has sent you a personalized email', recipient))
  end

  private

  def setup_email_options(email_type, subject_text, recipient, events=nil)
    # returns a hash containing strings of emails in :to, :cc, and :bcc keys
    recipient = parse_recipients(recipient)

    if recipient[:to].blank? && recipient[:cc].blank? && recipient[:bcc].blank?
      raise "ERROR: Trying to send email without any recipients. #{email_type} - #{subject_text}"
    end

    mail_options = {}
    mail_options[:from] = Setting.notifier_email_with_name
    mail_options[:reply_to] = Setting.notifier_email_with_name
    mail_options[:subject] = format_subject(subject_text)
    mail_options[:to] = recipient[:to] if recipient[:to].present?
    mail_options[:cc] = recipient[:cc] if recipient[:cc].present?
    mail_options[:bcc] = recipient[:bcc] if recipient[:bcc].present?

    # create an email log of what got sent and to whom for any staff instances
    # that were found during the parsing of to/cc/bcc data
    Array(@staff_instances).each do |contact|
      next unless contact.is_a?(Staff)

      details = {
        :email_type => email_type,
        :subject => subject_text,
        :staff => contact,
      }

      if events.is_a?(Array)
        events.each { |event| EmailLog.create!(details.merge(:event => event)) }
      else
        EmailLog.create!(details.merge(:event => events))
      end
    end

    mail_options
  end

  def format_subject(text)
    "#{Setting.site_name} - #{text}"
  end

  def parse_recipients(recipients)
    if recipients.is_a?(Hash)
      recipients.symbolize_keys!

      # Convert all values into an array to append to and loop over later
      [:to, :cc, :bcc].each do |type|
        value = recipients[type]
        recipients[type] = Array(value) unless value.is_a?(Array)
      end

      # Add site administrator to the email CC if enabled
      if Setting.administrators_get_special_emails && CC_TO_ADMIN.include?(@mailer_name)
        recipients[:cc] ||= Array.new
        recipients[:cc] += Setting.site_administrator_emails.uniq
      end

      # Format all recipients, and make sure the same email doesn't show up twice
      @contacted_emails = Array.new
      [:to, :cc, :bcc].each do |type|
        value = recipients[type]
        recipients[type] = value.collect do |v|
          email = format_recipient(v)
          email unless contacted_emails_includes?(email)
        end.compact
        @contacted_emails += recipients[type]
      end

      recipients
    else
      # Anything passed in other than a hash is considered a :to value
      parse_recipients({ :to => recipients })
    end
  end

  def contacted_emails_includes?(email)
    @contacted_emails.any? do |contacted|
      contacted =~ /#{Regexp.escape(email)}/ || email =~ /#{Regexp.escape(contacted)}/
    end
  end

  def format_recipient(recipient)
    if recipient.is_a?(Staff)
      @staff_instances ||= Array.new
      @staff_instances << recipient
      recipient.email_with_name
    else
      recipient
    end
  end

  def add_attachment(attachment_path)
    File.open(attachment_path) do |file|
      filename = File.basename(file.path)
      attachments[filename] = {:mime_type => File.mime_type?(file), :content => file.read}
    end
  end

  def add_attachments(attachment_paths)
    Array(attachment_paths).collect{ |path| add_attachment(path) }
  end

end
