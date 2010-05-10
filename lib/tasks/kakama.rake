DEFAULT_STAFF_NUM = 300
DEFAULT_STAFF_EMAIL = nil

class Range
  def rand
    to_a[(Kernel.rand * to_a.size).floor].to_i
  end
end

task :setup_demo => :environment do

  [ 'faker', 'seed-fu', ['ruby-progressbar', 'progressbar'] ].each do |gem_name, gem_lib|
    gem_lib ||= gem_name
    begin
      require gem_lib
    rescue LoadError
      puts "To run this task, you need the #{gem_name} gem."
      puts "  [sudo] gem install #{gem_name}"
      exit 1
    end
  end

  puts "--------------------------"
  puts "Setup Kakama Demonstration"
  puts "--------------------------"
  puts ""
  puts "You are about to setup the Kakama demonstration."
  puts ""
  puts "Available Options:"
  puts ""
  puts "  STAFF_NUM=x"
  puts "    Number of example staff to create, where x is a number."
  puts "    E.g. STAFF_NUM=100."
  puts "    Default: #{DEFAULT_STAFF_NUM} - Max: 1000"
  puts ""
  puts "  STAFF_EMAIL=.."
  puts "    The email to use on some staff members (you will be sent notifications to this email)."
  puts "    E.g. STAFF_EMAIL=you@home.com."
  puts "    Default: #{DEFAULT_STAFF_EMAIL ? DEFAULT_STAFF_EMAIL : 'none'}"
  puts ""
  puts "This will ERASE all data on the #{RAILS_ENV} database."
  puts "Are you sure you want to do this?"
  puts ""
  puts "Press any key to continue, or Ctrl+C to abort.."
  STDIN.gets

  puts ""
  puts "Setting up Kakama Demonstration..."
  puts ""

  staff_num = (ENV['STAFF_NUM'] || DEFAULT_STAFF_NUM).to_i
  staff_num = 1000 if staff_num > 1000
  staff_email = (ENV['STAFF_EMAIL'] || DEFAULT_STAFF_EMAIL)

  Rostering.all.each { |r| r.skip_staff_selections_callback = true; r.destroy }
  [StaffDetail, StaffRole, Availability, EmailLog, DetailType, Event, Role, Staff, Venue, Schedule].each do |model|
    model.send(:with_exclusive_scope) { model.all.each { |s| s.respond_to?(:destroy!) ? s.destroy! : s.destroy } }
  end

  %w{ detail_types roles schedules staffs venues }.each do |fixture|
    require Rails.root.join("db/fixtures/#{fixture}")
  end

  puts ""
  puts "Creating #{staff_num} fake staff members"

  pbar = ProgressBar.new("Kakama Demo", staff_num)

  home_phone = DetailType.find_by_name('Home Phone')
  work_phone = DetailType.find_by_name('Work Phone')
  cell_phone = DetailType.find_by_name('Cell Phone')
  physical_address = DetailType.find_by_name('Physical Address')
  postal_address = DetailType.find_by_name('Postal Address')

  staff_num.times do |time|
    username, first_name, last_name = find_unused_names
    staff = Staff.create!(
      :username => username,
      :staff_type => 'staff',
      :password => 'test',
      :password_confirmation => 'test',
      :email => (staff_email if staff_email && (rand * 100).to_i < 80),
      :full_name => "#{first_name} #{last_name}",
      :start_date => Time.now - (rand * 100).to_i.days,
      :admin_notes => (Faker::Lorem.paragraphs if (rand * 100).to_i < 50),
      :contact_details => {
        home_phone.id => (Faker.numerify('(0#) ###-####') if (rand * 100).to_i < 70),
        work_phone.id => (Faker.numerify('(0#) ###-####') if (rand * 100).to_i < 70),
        cell_phone.id => (Faker.numerify('02# ### ####') if (rand * 100).to_i < 70),
        physical_address.id => ((Faker::Address.street_address + "\n" + Faker::Address.city + "\nNew Zealand") if (rand * 100).to_i < 70),
        postal_address.id => ((Faker::Address.street_address + "\n" + Faker::Address.city + "\nNew Zealand") if (rand * 100).to_i < 70)
      },
      :role_ids => Role.all(:order => "rand()", :limit => (rand * Role.count).to_i).collect { |r| r.id }
    )

    if (rand * 100) < 95
      availability_collection = availability_collections[(rand * availability_collections.size).floor]
      availability_collection.each { |collection| Availability.create!(collection.merge(:staff_id => staff.id)) }
    end

    pbar.inc
  end

  pbar.finish

  puts ""
  puts "Kakama Demonstration Setup."
  puts ""

end

def find_unused_names
  first_name, last_name = Faker::Name.first_name, Faker::Name.last_name
  username = first_name.downcase.gsub(/\W/, '_')
  username.length < 3 || Staff.find_by_username(username) ? find_unused_names : [username, first_name, last_name]
end

# hours(:all, [[9,12], [13,17]])
def create_hours(days, start_and_finishes)
  days = [:mon, :tue, :wed, :thu, :fri, :sat, :sun] if days == :all
  days = [:mon, :tue, :wed, :thu, :fri] if days == :week
  days = [:sat, :sun] if days == :weekend

  hours = Hash.new
  Array(days).each do |day|
    hours[day] ||= Array.new
    start_and_finishes.each do |start, finish|
      hours[day] << { :start => start, :finish => finish }
    end
  end
  hours
end

def availability_collections
  beginning_of_year, end_of_year = Time.now.beginning_of_year, Time.now.end_of_year

  [
    # standard work year (mon-fri, 9am-5pm, except christmas/new years)
    [
      {
        :start_date => beginning_of_year + 5.days,
        :end_date => end_of_year - 8.days,
        :hours => create_hours(:week, [[9,17]])
      }
    ],
    # night shift worker (mon-fri, 8pm-7am)
    [
      {
        :start_date => beginning_of_year,
        :end_date => end_of_year,
        :hours => create_hours(:week, [[0,7], [20,24]])
      }
    ],
    # mid year holiday (takes off the month of July)
    [
      {
        :start_date => beginning_of_year,
        :end_date => beginning_of_year + 6.months,
        :hours => create_hours(:week, [[9,17]])
      },
      {
        :start_date => beginning_of_year + 7.months,
        :end_date => end_of_year,
        :hours => create_hours(:week, [[9,17]])
      }
    ],
    # four day work week (mon-thu, 9am-5pm)
    [
      {
        :start_date => beginning_of_year,
        :end_date => end_of_year,
        :hours => create_hours([:mon, :tue, :wed, :thu], [[9,17]])
      }
    ],
    # weekend worker (sat-sun, 9am-5pm)
    [
      {
        :start_date => beginning_of_year,
        :end_date => end_of_year,
        :hours => create_hours(:weekend, [[9,17]])
      }
    ],
    # seasonal worker (summer, 6am-8pm)
    [
      {
        :start_date => beginning_of_year - 2.months,
        :end_date => beginning_of_year + 2.months,
        :hours => create_hours(:week, [[6,20]])
      }
    ],
    # morning part timer (mon-fri, 9-12pm)
    [
      {
        :start_date => beginning_of_year,
        :end_date => end_of_year,
        :hours => create_hours(:week, [[9,12]])
      }
    ],
    # afternoon part timer (mon-fri, 12pm-5pm)
    [
      {
        :start_date => beginning_of_year,
        :end_date => end_of_year,
        :hours => create_hours(:week, [[12,17]])
      }
    ],
    # evening shift (mon-fri, 4pm-11pm)
    [
      {
        :start_date => beginning_of_year,
        :end_date => end_of_year,
        :hours => create_hours(:week, [[16,23]])
      }
    ],
    # after school facilities (mon-fri, 3pm-6pm)
    [
      {
        :start_date => beginning_of_year,
        :end_date => end_of_year,
        :hours => create_hours(:week, [[15,18]])
      }
    ],
    # bakers (mon-fri, 3am-9am)
    [
      {
        :start_date => beginning_of_year,
        :end_date => end_of_year,
        :hours => create_hours(:week, [[3,9]])
      }
    ],
    # luncheries (mon-fri, 11am-2pm)
    [
      {
        :start_date => beginning_of_year,
        :end_date => end_of_year,
        :hours => create_hours(:week, [[11,14]])
      }
    ],
    # bymonthly (Jan, Mar, May, Jul, Sep, Nov, 9m-5pm)
    [
      {
        :start_date => beginning_of_year,
        :end_date => beginning_of_year + 1.month,
        :hours => create_hours(:week, [[9,17]])
      },
      {
        :start_date => beginning_of_year + 2.months,
        :end_date => beginning_of_year + 3.months,
        :hours => create_hours(:week, [[9,17]])
      },
      {
        :start_date => beginning_of_year + 4.months,
        :end_date => beginning_of_year + 5.months,
        :hours => create_hours(:week, [[9,17]])
      },
      {
        :start_date => beginning_of_year + 6.months,
        :end_date => beginning_of_year + 7.months,
        :hours => create_hours(:week, [[9,17]])
      },
      {
        :start_date => beginning_of_year + 8.months,
        :end_date => beginning_of_year + 9.months,
        :hours => create_hours(:week, [[9,17]])
      },
      {
        :start_date => beginning_of_year + 10.months,
        :end_date => beginning_of_year + 11.months,
        :hours => create_hours(:week, [[9,17]])
      }
    ],
    # contracted, on-call etc (random times, random days)
    [
      {
        :start_date => beginning_of_year + (1..28).rand.days,
        :end_date => beginning_of_year + (1..2).rand.months + (1..28).rand.days,
        :hours => create_hours(:week, [[13,18]])
      },
      {
        :start_date => beginning_of_year + (3..4).rand.months + (1..28).rand.days,
        :end_date => beginning_of_year + (5..6).rand.months + (1..28).rand.days,
        :hours => create_hours(:week, [[6,9]])
      },
      {
        :start_date => beginning_of_year + (7..8).rand.months + (1..28).rand.days,
        :end_date => beginning_of_year + (9..10).rand.months + (1..28).rand.days,
        :hours => create_hours(:week, [[9,17]])
      },
      {
        :start_date => beginning_of_year + 11.months + (1..13).rand.days,
        :end_date => beginning_of_year + 11.months + (14..28).rand.days,
        :hours => create_hours(:week, [[8,20]])
      }
    ]
  ]
end
