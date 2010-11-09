# Extend MysqlAdapter to support ordering of columns, and custom MySQL options.
# Also note that this functionality was added in Rails 2.3.8 but this is slightly different.
#module ActiveRecord
#  module ConnectionAdapters
#    class MysqlAdapter < AbstractAdapter
#      def add_column_options!(sql, options) #:nodoc:
#        sql << " DEFAULT #{quote(options[:default], options[:column])}" if options_include_default?(options)
#        sql << " NOT NULL" if options[:null] == false
#        sql << " AFTER `#{options[:after]}`" if options[:after]
#        sql << " "+options[:options] if options[:options]
#      end
#    end
#  end
#end