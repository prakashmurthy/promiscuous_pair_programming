# Fix the Selenium driver in Capybara so that if an element cannot be found
# (via #find), Capybara stops short instead of hitting Selenium's internal
# findElement() method ad infinitum

#Capybara.register_driver :selenium do |app|
#  Capybara::Driver::Selenium.new(app).tap do |driver|
#    driver.browser.manage.timeouts.implicit_wait = 5 # seconds
#  end
#end

Capybara::Driver::Selenium.class_eval do
  def wait?; false; end
end
