Then /^I should not see the navigation area$/ do
  page.has_selector?("#navigation").should be_false
end

Then /^I should see the navigation area$/ do
  page.has_selector?("#navigation").should be_true
end