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
      when /my involved pairing sessions/
        '#my_involved_pairing_sessions'
      when /my open pairing sessions/
        '#my_open_pairing_sessions'
      when /available pairing sessions/
        '#available_pairing_sessions'
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
        # Probably straight CSS was given, let's just let it through then
        locator
    end
  end
end

World(HtmlSelectorsHelpers)
