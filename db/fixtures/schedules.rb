[
  ['Reoccurres Daily',       1, :day],
  ['Reoccurres Weekly',      1, :week],
  ['Reoccurres Fortnightly', 2, :week],
  ['Reoccurres Monthly',     1, :month]
].each do |name, interval, delay|
  Schedule.seed(:name) do |s|
    s.name = name
    s.interval = interval
    s.delay = Schedule::Delays[delay]
  end
end
