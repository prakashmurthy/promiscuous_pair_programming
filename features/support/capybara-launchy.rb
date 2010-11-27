module Capybara
  module SaveAndOpenPage
    def self.open_in_browser(path)
      # Use Chrome if that's open, otherwise use whichever browser Launchy picks
      # TODO: Probably need to submit this as a patch to Launchy....
      if system("ps aux | grep 'Google Chrome' | grep -v 'grep Google Chrome'")
        system("open -a '/Applications/Google Chrome.app' '#{path}'")
      else
        begin
          require "launchy"
          Launchy::Browser.run(path)
        rescue LoadError
          warn "Sorry, you need to install launchy to open pages: `gem install launchy`"
        end
      end
    end
  end
end