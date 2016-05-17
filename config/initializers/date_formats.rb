Time::DATE_FORMATS.merge!(
  :long_with_day => "%a %d %B, %Y %H:%M",
  :nz => "%d-%m-%Y %H:%M"
)

Date::DATE_FORMATS.merge!(
  :long_with_day => "%a %d %B",
  :nz => "%d-%m-%Y"
)
