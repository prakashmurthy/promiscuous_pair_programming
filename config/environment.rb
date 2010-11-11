require File.expand_path("../../vendor/require-profiler/lib/require-profiler", __FILE__)

RequireProfiler.profile do
  # Load the rails application
  require File.expand_path('../application', __FILE__)

  # Initialize the rails application
  PPP::Application.initialize!
end