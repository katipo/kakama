[ 'Town Square', 'Town Hall' ].each do |venue_name|
  Venue.seed(:name, true) do |v|
    v.name = venue_name
  end
end
