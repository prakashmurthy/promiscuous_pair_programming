When /^I will let through any Javascript alert$/ do
  page.execute_script("window.alert = function(msg) { return true; }")
end

When /^I will accept any Javascript confirmation$/ do
  page.execute_script("window.confirm = function(msg) { return true; }")
end

When /^I will reject any Javascript confirmation$/ do
  page.execute_script("window.confirm = function(msg) { return false; }")
end