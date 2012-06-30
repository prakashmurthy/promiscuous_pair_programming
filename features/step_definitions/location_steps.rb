Given /^my IP address is "([^"]*)"$/ do |remote_ip|
  params_for_next_url[:remote_ip] = remote_ip
end

Given /^(.+) exists as a location$/ do |location|
  factory = "location_" + location.downcase.gsub(" ", "_")
  Given %{a location "#{location}" exists using the "#{factory}" factory}
end