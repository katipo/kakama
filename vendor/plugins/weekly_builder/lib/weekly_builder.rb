module WeeklyBuilder

  def weekly_builder(events, options = {}, &block)
    WeeklyBuilder.new(events, options).to_html(self, &block)
  end
  alias :weekly_calendar :weekly_builder

  def weekly_links(time=Time.now)
    date = Date.new(time.year, time.month, time.day)
    start_date, end_date = date, (date + 6)
    links =  link_to('« Previous Week', :start_date => (start_date - 7))
    links += " #{start_date.strftime("%B %d -")} #{end_date.strftime("%B %d")} #{start_date.year} "
    links += link_to('Next Week »', :start_date => (start_date + 7))
    content_tag('div', links, :class => 'weekly_links')
  end

  class WeeklyBuilder
    include ::ActionView::Helpers

    def initialize(events, options)
      events ||= Array.new
      raise ArgumentError, "WeeklyBuilder expects an Array but found a #{events.inspect}" unless events.is_a? Array
      time = options[:time] || options[:date] || Time.now
      @events, @options, @date_period = events, options, get_date_period_for(time)
      @hours = hours_array # needs to be called after events are set
    end

    # It would be nice if this returned an HTML string for
    # testing purposes instead of using concat, but yield
    # writes directly the output and I didn't find a way
    # around this without weird results
    def to_html(template, &block)
      template.concat "<div class='weekly_builder'>"
        template.concat days_column
        template.concat "<div class='data #{"business_hours" if only_business_hours?}'>"
          template.concat hours_row
          @date_period.each do |day|
            template.concat "<div class='day'>"
            events_starting_on(day).each do |event|
              offset, width = calculate_offset(event), calculate_width(event)
              onclick = (@options[:with_onclick] ? "onclick=\" location.href='/events/#{event.id}';\"" : '')
              template.concat "<div class='event' style='left: #{offset}px; width:#{width}px;'#{onclick}><div>"
                yield(event)
              template.concat "</div></div>"
            end
            template.concat "</div>"
          end
        template.concat "</div>"
        template.concat "<div style='clear:both'></div>"
      template.concat "</div>"
    end

    private

    def get_date_period_for(time)
      date = Date.new(time.year, time.month, time.day)
      start_date, end_date = date, (date + 6)
      (start_date..end_date)
    end

    def hours_array
      only_business_hours? ?
        ["6am","7am","8am","9am","10am","11am","12pm","1pm","2pm","3pm","4pm","5pm","6pm","7pm"] :
        ["12am","1am","2am","3am","4am","5am","6am","7am","8am","9am","10am","11am",
          "12pm","1pm","2pm","3pm","4pm","5pm","6pm","7pm","8pm","9pm","10pm","11pm"]
    end

    def only_business_hours?
      @events.any? do |e|
        e.starts_at.day != e.ends_at.day ||
        e.starts_at.hour < settings[:business_start_hour] ||
          e.ends_at.hour > settings[:business_end_hour]
      end ? false : true
    end

    def events_starting_on(day)
      @events.select { |e| e.starts_at.strftime('%Y-%m-%d') == day.strftime('%Y-%m-%d') }
    end

    def days_column
      days = ''
      @date_period.each do |day|
        day_name = content_tag('div', day.strftime('%A'), :class => 'name')
        day_date = content_tag('div', day.strftime('%B %d'), :class => 'date')
        days += content_tag('div', day_name + day_date, :class => 'day')
      end
      placeholder = content_tag('div', '<div>Weekly View</div>', :class => "placeholder")
      content_tag('div', placeholder + days, :class => 'days_column')
    end

    def hours_row
      hours = ''
      @hours.each do |hour|
        hours += content_tag("div", "<div>#{hour}</div>", :class => "hour")
      end
      content_tag('div', hours, :class => 'hours_row')
    end

    def calculate_offset(event)
      start_minute = event.starts_at.strftime('%M').to_f * css[:pixels_per_minute]
      start_hour = event.starts_at.strftime('%H').to_f
      start_hour -= settings[:business_start_hour] if only_business_hours?
      (start_hour * css[:day_width]) + start_minute
    end

    def calculate_width(event)
      difference = event.ends_at - event.starts_at
      total_minutes = difference / 60
      total_hours = total_minutes / 60
      remaining_minutes = (total_minutes - (total_hours.floor * 60)).ceil
      hours_width = total_hours * css[:day_width]
      minutes_width = remaining_minutes * css[:pixels_per_minute]
      (hours_width + minutes_width) - css[:event_border]
    end

    protected

    def settings
      {
        :business_start_hour => 6,
        :business_end_hour => 20
      }
    end

    def css
      {
        :day_width => 75,            # full width (63px plus padding and border)
        :event_border => 4,          # the width of the border on the left of each event
        :pixels_per_minute => 1.25   # 1.25 pixels per minute = 75 pixels per hour / 60 minutes per hour
      }
    end
  end
end