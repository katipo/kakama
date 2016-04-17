Given /^(?:I|they|"([^\"]*)") (?:have|has) the role "([^\"]*)"$/ do |full_name, role_name|
  find_or_create_role(role_name)
  staff = full_name ? Staff.find_by_full_name!(full_name) : @current_staff
  staff.roles << @role
end

When /^I try to delete the role "([^\"]*)", I should be refused to access the record$/ do |role_name|
  visit delete_role_path(find_or_create_role(role_name))
  expect(page).to have_content('Are you sure you want to delete ?')
  click_button('Delete')
  expect(page).to have_content('You cannot delete this role because it is still assigned to staff members.')
end
