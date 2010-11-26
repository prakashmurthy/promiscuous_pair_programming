module QueryTrace
  mattr_accessor :depth
  self.depth = 20
  
  def self.enabled?
    defined?(@@trace_queries) && @@trace_queries
  end
     
  def self.enable!
    ::ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, QueryTrace) unless defined?(@@trace_queries)
    @@trace_queries = true
  end
  
  def self.disable!
    @@trace_queries = false
  end

  # Toggles query tracing on and off and returns a boolean indicating the new
  # state of query tracing (true for enabled, false for disabled).
  def self.toggle!
    enabled? ? disable! : enable!
    enabled?
  end
  
  def self.append_features(klass)
    super
    klass.class_eval do
      unless method_defined?(:log_without_trace)
        alias_method :log_without_trace, :log
        alias_method :log, :log_with_trace
      end
    end
  end

  def log_with_trace(sql, name, &block)
    result = log_without_trace(sql, name, &block)

    return result unless @@trace_queries

    return result unless ActiveRecord::Base.logger and ActiveRecord::Base.logger.debug?
    return result if / Columns$/ =~ name

    #ActiveRecord::Base.logger.debug(format_trace(Rails.backtrace_cleaner.clean(caller)[0..self.depth]))
    #ActiveRecord::Base.logger.debug(format_trace(caller[0..self.depth]))
    
    logs = caller #Rails.backtrace_cleaner.clean(caller)
    logs = logs.grep(/#{Rails.root}/)[0..self.depth]
    ActiveRecord::Base.logger.debug(format_trace(logs))

    result 
  end

  def format_trace(trace)
    if (defined?(ActiveRecord::LogSubscriber) ? ActiveRecord::LogSubscriber : ActiveRecord::Base).colorize_logging
      message_color = "30;1"
      trace.collect{|t| "    \e[#{message_color}m#{t}\e[0m"}.join("\n")
    else
      trace.join("\n    ")
    end
  end
end

QueryTrace.enable! if ENV["QUERY_TRACE"]
