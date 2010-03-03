module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /^the dashboard$/
      dashboard_path

    when /^login$/
      login_path

    when /^logout$/
      logout_path

    when /^my profile$/
      staff_path(:current)

    when /^the staff list$/
      staffs_path

    when /^add a new staff member$/
      new_staff_path

    when /^edit the staff member "([^\"]*)"$/
      edit_staff_path(Staff.find_by_full_name!($1))

    when /^edit my details$/
      edit_staff_path(:current)

    when /^delete the staff member "([^\"]*)"$/
      destroy_staff_path(Staff.find_by_full_name!($1))

    when /^send (?:everyone|"([^\"]*)") an email$/
      if $1
        contact_staff_path(Staff.find_by_full_name!($1))
      else
        contact_all_staffs_path
      end

    when /^enter my reset token$/
      password_resets_path

    when /^reset my password$/
      new_password_reset_path

    when /^reset my password with token "([^\"]*)"$/
      edit_password_reset_path($1)

    when /^reset my password with the valid token of "([^\"]*)"$/
      edit_password_reset_path(Staff.find_by_full_name!($1).perishable_token)

    when /^the venues list$/
      venues_path

    when /^view the venue$/
      venue_path(@venue)

    when /^delete the venue$/
      delete_venue_path(@venue)

    when /^the events list$/
      events_path

    when /^the past events list$/
      events_path(:type => 'past')

    when /^the working events list$/
      events_path(:type => 'working')

    when /^the cancelled events list$/
      events_path(:type => 'cancelled')

    when /^add an event$/
      new_event_path

    when /^view the event$/
      event_path(@event)

    when /^edit the event$/
      edit_event_path(@event)

    when /^delete the event$/
      destroy_event_path(@event)

    when /^cancel the event$/
      cancel_event_path(@event)

    when /^my availability$/
      staff_availabilities_path(:current)

    when /^add an availability$/
      new_staff_availability_path(:current)

    when /^edit my current availability$/
      edit_staff_availability_path(:current, :current)

    when /^edit the current availability of "([^\"]*)"$/
      edit_staff_availability_path(Staff.find_by_full_name!($1), :current)

    when /^split my current availability$/
      split_staff_availability_path(:current, :current)

    when /^remove my current availability$/
      destroy_staff_availability_path(:current, :current)

    when /^the roles list$/
      roles_path


    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
