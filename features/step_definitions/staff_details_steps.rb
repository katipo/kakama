Given /^my contact details are set$/ do
  When 'I go to edit my details'
  And 'I fill in "Home Phone" with "01 234 5678"'
  And 'I fill in "Work Phone" with "12 345 6789"'
  And 'I fill in "Cell Phone" with "23 456 7890"'
  And 'I fill in "Physical Address" with "123 Somewhere, Someplace, Somecountry"'
  And 'I fill in "Postal Address" with "Same as physical address"'
  And 'I press "Save"'
end
