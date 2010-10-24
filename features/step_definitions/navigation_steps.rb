Then /^I should not see the navigation area$/ do
  page.has_css?("#navigation").should be_false
end
