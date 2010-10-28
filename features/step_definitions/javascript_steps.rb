When /^I confirm any js alerts$/ do
  page.evaluate_script("window.alert = function(msg) { return true; }")
end

When /^I answer OK to any js confirmations$/ do
  page.evaluate_script("window.confirm = function(msg) { return true; }")
end

When /^I answer Cancel to any js confirmations$/ do
  page.evaluate_script("window.confirm = function(msg) { return false; }")
end