#------------------
# require-profiler
# Author: Elliot Winkler <elliot.winkler@gmail.com>
# Version: 0.3.pre (10 Nov 2010)
# You can always find the latest stable version at: http://gist.github.com/277289
#------------------ 
#
# WHAT IS THIS?
#
# This script of sorts overrides 'require' and `load` to record the time it takes
# to require files within a section of your code, and then generates a report
# afterward. It's intelligent enough to figure out where files were required
# from and construct a hierarchy of the required files.
#
# INSTALLATION
#
# First, `gem install term-ansicolor` so you can see the reports in color
# (which I think you'll appreciate).
#
# Next, require this file somewhere and wrap the code you want to
# measure in a `profile` block. Like so:
#
#   require '/path/to/lib/require-profiler'
#   RequireProfiler.profile do
#     # load, say, your boot or environment file here
#   end
#
# Alternatively, you can use `start` and `stop`:
#
#   require '/path/to/lib/require-profiler'
#   RequireProfiler.start
#   # load, say, your boot or environment file here
#   RequireProfiler.stop
#
# For a Rails app, we want to stop the profiler after the application is initialized.
# For Rails 2, you can place the following at the top of the Rails::Initializer
# block in your config/environment.rb file:
#
#   require File.expand_path(File.dirname(__FILE__) + '/../lib/require-profiler')
#   RequireProfiler.start
#   config.after_initialize { RequireProfiler.stop }
#
# For Rails 3, you can simply wrap everything in config/environment.rb in a `profile`
# block, so the file looks something like:
#
#   require File.expand_path(File.dirname(__FILE__) + '/../lib/require-profiler')
#   RequireProfiler.profile do
#     # Load the rails application
#     require File.expand_path('../application', __FILE__)
#     # Initialize the rails application
#     YourApp::Application.initialize!
#   end
#
# GENERATING THE REPORT
#
# Now all you have to do is run your code by passing PROFILE=1 as an environment
# variable on the command line. For instance, if you were running a Rails app,
# you'd say script/server PROFILE=1` (or `rails server PROFILE=1` for Rails 3).
#
# When profiling stops, a report will be written to APP_DIR/tmp/require_profile.log
# (or /tmp/require_profile.log, if APP_DIR/tmp doesn't exist). If you ever need to
# regenerate this report, simply run:
#
#   ruby bin/generate-report
#
# There are several command options that let you customize the report. To view
# them, say:
#
#   ruby bin/generate-report --help
#
# KNOWN ISSUES
#
# * Files that are autoload'ed (as is common these days) are not caught by this
#   script. This is because Kernel.autoload doesn't call Kernel#require or even
#   Kernel.require, but an internal require method (<http://is.gd/9VtxI>).
#   See next point.
# * Files that are required within the Ruby source using rb_safe_require() or
#   anything like that aren't caught, either. In order to measure these requires,
#   you'd have to override the relevant C methods, too. Unfortunately I don't
#   know how to do this, but if you want to take a crack at it, feel free!
#   Be sure to let me know so I can try it out too.
#

require 'benchmark'
require 'yaml'
require 'set'

module RequireProfiler
  class << self
    def profiling_enabled?
      @profiling_enabled
    end
    
    def options
      @options ||= default_options.dup
    end
    attr_writer :options
    
    def colorize_strings
      begin
        require 'term/ansicolor'
      rescue LoadError
        raise "\n\nYou need to install the term-ansicolor gem to see colorized reports.\n\n"
      end
      String.class_eval { include Term::ANSIColor }
      Term::ANSIColor.coloring = true
    end
    
    def profile(tmp_options={}, &block)
      current_options = options
      @options = tmp_options
      start
      yield
      stop
      self.options = current_options
    end
    
    def start(tmp_options={})
      return unless ENV["PROFILE"] or $PROFILE
      colorize_strings
      @start_time = Time.now
      [ ::Kernel, (class << ::Kernel; self; end) ].each do |klass|
        klass.class_eval do
          def require_with_profiling(path, *args)
            RequireProfiler.measure(path, caller, :require) { require_without_profiling(path, *args) }
          end
          alias require_without_profiling require
          alias require require_with_profiling
          
          def load_with_profiling(path, *args)
            RequireProfiler.measure(path, caller, :load) { load_without_profiling(path, *args) }
          end
          alias load_without_profiling load
          alias load load_with_profiling
        end
      end
      # This is necessary so we don't clobber Bundler.require on Rails 3
      Kernel.class_eval { private :require, :load }
      @profiling_enabled = true
    end
    
    def stop
      return unless ENV["PROFILE"] or $PROFILE
      @stop_time = Time.now
      [ ::Kernel, (class << ::Kernel; self; end) ].each do |klass|
        klass.class_eval do
          alias require require_without_profiling
          alias load load_without_profiling
        end
      end
      store_profile_data
      @profiling_enabled = false
    end
    
    def measure(path, full_backtrace, mechanism, &block)
      # Don't worry about measuring the require if the file's already in $"
      # (since Ruby will just not require it, anyway)
      return yield if $".include?(path)
      
      num_files = required_files.size
      
      output = nil
      backtrace = full_backtrace.reject {|x| x =~ /require|dependencies/ }
      caller = File.expand_path(backtrace[0].split(":")[0])
      parent = required_files.find {|f| f[:full_path] == caller }
      unless parent
        #puts "Couldn't find parent '#{caller}' for '#{path}', making fake"
        #puts backtrace.join("\n")
        #puts
        parent = {
          :index => required_files.size,
          :full_path => caller,
          :parent => nil,
          :is_root => true,
          :fake => true
        }
        required_files << parent
      end
      full_path = find_file(path)
      expanded_path = path; expanded_path = expand_absolute_path(path) if path =~ /^\//
      new_file = {
        :index => required_files.size,
        :original_path => path,
        :path => expanded_path,
        :full_path => full_path,
        :backtrace => full_backtrace,
        :parent => parent,
        :is_root => false,
        :is_fake_root => parent[:fake],
        :loaded_via => mechanism
      }
      # add this before the file is required so that anything that is required
      # within the file that's about to be required already has a parent present
      required_files << new_file
      time = Time.now
      begin
        output = yield  # do the require or load here
        new_file[:time] = (Time.now - time)
      rescue LoadError => e
        # Hmm, looks like the file didn't exist. Remove this file and any files
        # that may have been required inside it. Oh and if we created a fake parent,
        # remove that too.
        #puts "Hmm, had a problem loading '#{path}'. Rolling back:"
        #required_files[num_files..required_files.size-1].each do |file|
        #  puts " - #{file[:full_path] || file[:original_path]}"
        #end
        #puts
        required_files.slice!(num_files..required_files.size-1)
        raise(e)
      end
      output
    end
 
    def store_profile_data
      FileUtils.mkdir_p(File.dirname(data_file))
      report_data = {
        :start_time => @start_time,
        :stop_time => @stop_time,
        :required_files => @required_files
      }
      File.open(data_file, "w") {|f| YAML.dump(report_data, f) }
      puts "Wrote data to #{data_file}." unless options[:stdout]
      generate_profile_report
    end

    def generate_profile_report(regenerating_report=false)
      unless options[:stdout]
        puts "Now generating profile report, please wait..."
      end
      
      if regenerating_report
        report_data = File.open(data_file) {|f| YAML.load(f) }
        @start_time = report_data[:start_time]
        @stop_time = report_data[:stop_time]
        @required_files = report_data[:required_files]
      end
      
      @required_files = remove_duplicate_files(@required_files)
      
      if options[:stdout]
        report_fh = $stdout
      else
        FileUtils.mkdir_p(File.dirname(report_file))
        report_fh = File.open(report_file, "w")
      end
      report_fh.puts(("Total time: %.2f seconds" % (@stop_time - @start_time)).bold.white)
      report_fh.puts
      if options[:nested] || options[:list] == :root
        if options[:nested]
          root_files = @required_files.select {|file| file[:is_root] }
        else
          root_files = @required_files.select {|file| file[:is_root] || file[:is_fake_root] }
        end
        out, total_time, children_total_time = generate_profile_report_level(root_files)
      else
        #generate_profile_report_level(@required_files.select {|file| !file[:is_root] && file[:time] }, true)
        out, total_time, children_total_time = generate_profile_report_level(@required_files)
      end
      report_fh.write(out)
      report_fh.close unless options[:stdout]
      
      unless options[:stdout]
        out = "Wrote report to #{report_file}."
        out << " Run `ruby bin/generate-report` if you want to regenerate the report." unless regenerating_report
        puts(out)
      end
    end
    
    def parse_argv(argv)
      return if argv.empty?
      argv = argv.dup
      @options = {}
      while arg = argv.shift
        case arg
        when "--help"
          puts
          puts "ruby #{$0} [OPTIONS]"
          puts
          puts "OPTIONS:"
          puts "--list (all|root)        - Lists all files, or just the top-level ones."
          puts "--all                    - Short for --list all --order ascending."
          puts "--root                   - Short for --list root --order ascending."
          puts "--nested                 - Arranges files in a hierarchy. Implies --all."
          puts "--sort (time|index)      - Sorts files by how long it took to require them, or the order in which they were required."
          puts "                           (Technically, --sort time is really --sort time,index, and index is always ascending.)"
          puts "--sequential             - Short for --sort index --order ascending."
          puts "--temporal               - Short for --sort time --order descending."
          puts "--order (asc|desc)       - For --sort time, orders files by earliest-to-latest, or latest-to-earliest."
          puts "                           For --sort index, orders files by first-to-last, or last-to-first."
          puts "--ascending, --asc       - Short for --order asc."
          puts "--descending, --desc     - Short for --order desc."
          puts "--stdout                 - Prints report to stdout instead of storing in a file."
          puts "--no-color               - By default, relevant parts of the output is colored."
          puts "                           This allows you turn it off for whatever reason."
          puts
          puts "Default options: --root --sort time --descending"
          puts
          exit
        when "--descending", "--desc"
          @options[:order] = :desc
        when "--ascending", "--asc"
          @options[:order] = :asc
        when "--sequential"
          @options[:sort] = :index
          @options[:order] ||= :asc
        when "--temporal"
          @options[:sort] = :time
          @options[:order] ||= :desc
        when "--all"
          @options[:list] = :all
          @options[:order] ||= :asc
        when "--root"
          @options[:list] = :root
          @options[:order] ||= :asc
        when "--nested"
          @options[:list] = :all
          @options[:nested] = true
        when "--stdout"
          @options[:stdout] = true
        when "--no-color"
          Term::ANSIColor.coloring = false
        when /--(.+)/
          @options[$1.to_sym] = argv.shift.to_sym
          @options[:order] ||= :asc if $1 == "list"
        end
      end
      @options = default_options.merge(@options)
    end
    
  private
    def default_options
      {:sort => :time, :order => :desc, :list => :root, :nested => false, :color => true}
    end
  
    def required_files
      @required_files ||= []
    end
    
    def data_file
      "#{tmp_dir}/require_profile.yml"
    end
    
    def report_file
      "#{tmp_dir}/require_profile.log"
    end
    
    def app_dir
      # TODO: This will break down once this is loaded from a gem
      @app_dir ||= File.expand_path("../../../..", __FILE__)
    end
    
    def tmp_dir
      @tmp_dir ||= File.exists?("#{app_dir}/tmp") ? "#{app_dir}/tmp" : Dir.tmpdir
    end
  
    def find_file(path)
      return expand_absolute_path(path) if path =~ /^\//
      expanded_path = nil
      # Try to find the path in the ActiveSupport load paths and then the built-in load paths
      # I'm not really sure if this is how Rails does it, so correct me if I'm wrong
      load_paths = []
      if defined?(ActiveSupport) && defined?(ActiveSupport::Dependencies)
        if ActiveSupport::Dependencies.respond_to?(:load_paths)
          # ActiveSupport 2
          load_paths += ActiveSupport::Dependencies.load_paths
        else
          # ActiveSupport 3
          load_paths += ActiveSupport::Dependencies.autoload_paths
        end
      end
      load_paths += $:
      catch :found_path do
        %w(rb bundle so).each do |ext|
          path_suffix = path; path_suffix = "#{path}.#{ext}" unless path_suffix =~ /\.#{ext}$/
          load_paths.each do |path_prefix|
            possible_path = File.join(path_prefix, path_suffix)
            if File.file? possible_path
              expanded_path = File.expand_path(possible_path)
              throw :found_path
            end
          end
          expanded_path
        end
      end
      #warn "find_file: Couldn't find '#{path}'" if expanded_path.nil?
      expanded_path
    end
    
    def expand_absolute_path(path)
      return File.expand_path(path) if path =~ /\.[^.]+$/
      %w(rb bundle so).each do |ext|
        newpath = File.expand_path(path + "." + ext)
        return newpath if File.exists?(newpath)
      end
      raise "Couldn't expand path '#{path}'!"
    end
    
    def remove_duplicate_files(files)
      #if file[:parent] && options[:list] == :all
      #  next if file[:index] < file[:parent][:index]
      #end
      files
    end
    
    def sort_proc
      @sort_proc ||= begin
        if options[:sort] == :time
          if options[:order] == :desc
            lambda {|f| [ -(f[:time] || 0), f[:index] ] }
          else
            lambda {|f| [ (f[:time] || 0), f[:index] ] }
          end
        else
          if options[:order] == :desc
            lambda {|f| -f[:index] }
          else
            lambda {|f| f[:index] }
          end
        end
      end
    end
  
    def generate_profile_report_level(files, indent_level=0)
      files = files.sort_by(&sort_proc)
      out = ""
      total_time = 0
      children_total_time = 0
      for file in files
        child_out, child_total_time = nil, nil
        if options[:nested]
          children = @required_files.select {|f| f[:parent] == file }
          if children.any?
            child_out, child_total_time, child_children_total_time = generate_profile_report_level(children, indent_level+1)
            children_total_time += child_children_total_time
          end
        end
        
        path = file[:full_path] ? format_path(file[:full_path]) : file[:path]

        line = ""
        line << (("%d)" % (file[:index]+1)).rjust(4)).yellow
        line << " #{path}"
        if file[:loaded_via]
          line << (" (#{file[:loaded_via]})").bold.black
        end
        if file[:time]
          ms = file[:time].to_f * 1000
          line << (" [%.1f ms]" % ms).magenta.bold
          total_time += file[:time]
        end
        if child_total_time
          ms = child_total_time.to_f * 1000
          line << (" [%.1f ms children]" % ms).green.bold
        end
        if !file[:parent] && file[:fake]
          line << (" (already loaded)").bold.black
        end
        out << ("  " * indent_level) + line + "\n"
        out << child_out if child_out
      end
      [out, total_time, children_total_time]
    end

    def format_path(path)
      path.sub(app_dir, "APP_DIR")
    end
  end
end