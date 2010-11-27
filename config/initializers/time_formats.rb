# TODO: Update this to be more user-friendly. Something like this:
#
#   lambda {|date|
#     # BSD strftime (which is what Mac uses) isn't as robust as GNU strftime
#     # so we have to format some stuff ourselves...
#     is_pm = (date.hour == 0 || date.hour > 12)
#     "#{date.month}/#{date.day}/%Y #{date.hour}:%M #{is_pm ? "pm" : "am"}"
#   }
#
Time::DATE_FORMATS[:default] = "%Y-%m-%d %I:%M%p"