Given /^my contact details are set$/ do
  step 'I go to edit my details'
  step 'I fill in "Home Phone" with "01 234 5678"'
  step 'I fill in "Work Phone" with "12 345 6789"'
  step 'I fill in "Cell Phone" with "23 456 7890"'
  step 'I fill in "Physical Address" with "123 Somewhere, Someplace, Somecountry"'
  step 'I fill in "Postal Address" with "Same as physical address"'
  step 'I press "Save"'
end
