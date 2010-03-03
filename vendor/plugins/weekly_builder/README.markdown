# Weekly Builder

A weekly calendar builder for Ruby on Rails.

Although there are countless monthly calendars on Github, there wasn't any with a weekly view, so Dan McGrady built his own, inspired by P8s table_builder which he recommends for monthly calendars.

However, there were several bugs in the original implementation, so I've gone ahead and fixed these, and rewritten it nearly from scratch. The usage is now more precise, the code is easier to maintain (and eventually write tests for), and include several new changes that make the calendar easier to use (such as auto showing 24 hours when events exists outside business hours).

## About

The calendar is horizontally scrolling with a completely fluid CSS layout. Weekly views are useful because the events are plotted based on time and the width is determined by how long the event is scheduled for. So there is a visual representation of when the event is, not just a list.

## Example

A live demo of the original implementation of this plugin are available at:

[http://scheduler.integratehq.com](http://scheduler.integratehq.com)

While the backend was rewritten, the look and feel of the calendar haven't changed (so what you see there is very similar to the new implementation).

## Install

    script/plugin install git://github.com/KieranP/weekly_builder.git

Then check the output if all images and stylesheets have been copied successfully.

## Usage

First, put this in your controller action:

    @time = Chronic.parse(params[:start_date]) || Time.now.utc
    start_date = Date.new(@time.year, @time.month, @time.day)
    @events = Event.find(:all, :conditions => ['starts_at between ? and ?', start_date, start_date + 7])

The calendar builder:

    <% weekly_builder(@events, :time => @time) do |event|  %>
      <%= event.starts_at.strftime('%I:%M%p')  %><br />
      <%= link_to event.name, event_path(event)  %>
    <% end -%>

The Next/Previous week links helper:

    <%= weekly_links(@time) %>

The event model only requires 2 attributes for the calendar system to work:

* `starts_at:datetime`
* `ends_at:datetime`

Using these two, the plugin calculates width and position on the calendar.

### Options available:

* `:with_onclick`:
  By default, events are clickable. They go to /events/[events_id]
  If this is not the correct path, disable the onclick feature.

## Todo

* Provide a controller method to encapsulate Time parsing, date generation and events collection, and then remove the need to pass these to the `weekly_builder` and `weekly_links` view methods
* Add the ability to change the default fields the calendar uses, for example, changing `starts_at` to `starting_time`
* IE6 and IE7 Friendly (so far only tested on FF3 + Safari 4)
* Localization/Internationalization
* Add a proper test suite for as much as possible (will be limited until we can get around having to use Rails concat method)

## Credits

* Copyright (c) 2009 Dan McGrady [http://dmix.ca](http://dmix.ca), released under the MIT license.
* Thanks to P8 [http://github.com/p8/table_builder](http://github.com/p8/table_builder) for the original implementations inspiration.
* Rewrite completed by Kieran Pilkington ([http://github.com/KieranP](http://github.com/KieranP)
