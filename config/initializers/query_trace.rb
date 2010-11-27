# Show backtraces under queries in the log
# From: http://github.com/jbwiv/query_trace
# (Original: http://github.com/ntalbott/query_trace)
QueryTrace.enable! unless Rails.env.production?