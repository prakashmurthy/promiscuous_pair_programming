# See http://openhood.com/rack/ruby/2010/07/15/rack-test-warning/
# and http://github.com/brianmario/escape_utils
# for more information

require 'escape_utils/html/rack' # to patch Rack::Utils
require 'escape_utils/html/erb' # to patch ERB::Util
require 'escape_utils/html/cgi' # to patch CGI

module Rack
  module Utils
    def escape(s)
      EscapeUtils.escape_url(s)
    end
  end
end