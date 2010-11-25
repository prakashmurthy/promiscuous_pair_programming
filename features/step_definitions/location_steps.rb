Given /^my IP address is "([^"]*)"$/ do |remote_ip|
  params_for_next_url[:remote_ip] = remote_ip
end