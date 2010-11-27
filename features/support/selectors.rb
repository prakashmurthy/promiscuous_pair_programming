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
        '#my_pairing_sessions'
      when /available pairing sessions/
        '#available_pairing_sessions'
      when /sessions I am pairing on/
        '#paired_sessions'
      when /the account management section/
        "#account_management"
      when /the navigation/
        "#navigation"
      when /the flash messages/
        ".flashes"
      when /the pairing sessions form/
        '#pairing_sessions_form'
      when /the pairing sessions/
        ".pairing-sessions"
      when /the welcome section/
        "#welcome"

        # Add more mappings here.
        # Here is an example that pulls values out of the Regexp:
        #
        #  when /the (notice|error|info) flash/
        #    ".flash.#{$1}"

      #else
      #  raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
      #            "Now, go and add a mapping in #{__FILE__}"
      
      else
        # Allow straight CSS as the locator
        locator
    end
  end
end

World(HtmlSelectorsHelpers)
