// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui/datepicker
//= require_tree .
//= require moment
//= require fullcalendar

$(document).ready(function() {
    dpElement = $('#datepicker')
        dpElement.datepicker({
          dateFormat: "yy-mm-dd",
          minDate: dpElement.data("min"),
          maxDate: dpElement.data("max")
        });

    cal = $('#calendar')

    cal.fullCalendar({
        defaultView: 'agendaWeek',
        minTime: '06:00:00',
        maxTime: '19:00:00',
        eventRender: function(event){
            return (event.ranges.filter(function(range){ // test event against all the ranges

                return (event.start.isBefore(range.end) &&
                        event.end.isAfter(range.start));

            }).length)>0; //if it isn't in one of the ranges, don't render it (by returning false)
        },
        events: eval(cal.data('availabilities'))
    })

});
