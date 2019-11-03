Staff.seed(:username) do |u|
  u.username = 'admin'
  u.staff_type = 'admin'
  u.password = 'test'
  u.password_confirmation = 'test'
  u.full_name = 'Administrator'
  u.email = 'admin@kakama.org'
  u.start_date = Time.now
  u.single_access_token = '123456'
end
