Staff.seed(:username) do |u|
  u.username = 'admin'
  u.staff_type = 'admin'
  u.password = 'test'
  u.password_confirmation = 'test'
  u.full_name = 'Administrator'
  u.email = 'admin@changeme.com'
  u.start_date = Time.now
end
