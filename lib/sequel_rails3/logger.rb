# see activerecord/lib/active_record/log_subscriber.rb
module SequelRails3
  class Logger
    cattr_accessor :logger
    cattr_accessor :odd_or_even
    cattr_accessor :helper

    self.logger = nil
    self.odd_or_even = false
    self.helper = ActiveSupport::LogSubscriber.new

    def self.runtime=(value)
      Thread.current["sequel_sql_runtime"] = value
    end

    def self.runtime
      Thread.current["sequel_sql_runtime"] ||= 0
    end

    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def self.debug(sql, duration)
      self.runtime += duration
      return unless logger && logger.debug?

      name = '(%.1fms)' % [duration*1000]
      sql  = sql.squeeze(' ')

      if odd?
        name = helper.send(:color, name, ActiveSupport::LogSubscriber::CYAN, true)
        sql  = helper.send(:color, sql, nil, true)
      else
        name = helper.send(:color, name, ActiveSupport::LogSubscriber::MAGENTA, true)
      end

      logger.debug "  #{name}  #{sql}"
    end

    def self.odd?
      self.odd_or_even = !odd_or_even
    end
  end
end

module Sequel
  class Database
    def log_yield(sql, args = nil)
      sql = "#{sql}; #{args.inspect}" if args
      start = Time.now
      result = yield
      SequelRails3::Logger.debug(sql, Time.now-start)
      result
    end
  end
end
