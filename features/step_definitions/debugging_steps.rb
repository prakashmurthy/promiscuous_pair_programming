When /^I debug$/ do
  debugger
end
When /^show me the mail queue$/ do
  puts "Here is the mail queue:"
  ActionMailer::Base.deliveries.each do |mail|
    puts mail.inspect
  end
end