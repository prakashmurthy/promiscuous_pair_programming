module HtmlSelectorsHelpers
  # Maps a name to a selector. Used primarily by the
  #
  #   When /^(.+) within (.+)$/ do |step, scope|
  #
  # step definitions in web_steps.rb
  #
  def selector_for(locator)
    case locator

      when /the page/
        "html > body"
      when /my pairing sessions/
        'html > body  #my_pairing_sessions'
      when /available pairing sessions/
        'html > body  #available_pairing_sessions'
      when /sessions I am pairing on/
        'html > body  #paired_sessions'
      when /the account management section/
        "html > body  #account_management"
      when /the navigation/
        "html > body  #navigation"
      when /the flash messages/
        "html > body .flashes"
      when /the pairing sessions/
        "html > body .pairing-sessions"

        # Add more mappings here.
        # Here is an example that pulls values out of the Regexp:
        #
        #  when /the (notice|error|info) flash/
        #    ".flash.#{$1}"

      else
        raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
                  "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)
