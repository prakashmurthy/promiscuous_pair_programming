Given /^(?:today is|the time is) "?([^"]*)"?$/ do |time|
  Timecop.freeze Time.zone.parse(time)
end