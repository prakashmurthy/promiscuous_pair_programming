require 'query_trace'

def status
  QueryTrace.enabled? ? "enabled" : "disabled"
end

puts "=> QueryTrace #{status}; CTRL-\\ to toggle"

trap("QUIT") do
  # Sending 2 backspace characters removes the ^\ that is 
  # printed to the console.
  rm_noise = "\b\b"

  QueryTrace.toggle!
  puts "#{rm_noise}=> QueryTrace #{status}"
end
