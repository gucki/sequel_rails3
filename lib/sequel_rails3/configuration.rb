module SequelRails3
  class Configuration < Hash
    def initialize(app)
      super

      config = app.config.database_configuration
      unless config && config[Rails.env]
        raise ArgumentError, "no database configured for environment #{Rails.env}"
      end

      replace(config[Rails.env])
    end

    def normalize!
      symbolize_keys!

      each_pair do |k, v|
        case k
          when :uri
            self[:url] = delete(:uri)
          when :adapter
            case v.to_sym
              when :sqlite3
                self[k] = :sqlite
              when :postgresql
                self[k] = :postgres
            end
        end
      end

      # always use jdbc when running jruby
      if defined?(JRUBY_VERSION)
        if self[:adapter]
          case self[:adapter].to_sym
            when :postgres
              self[:adapter] = :postgresql
          end
          self[:adapter] = "jdbc:#{self[:adapter]}"
        end
      end

      # some adapters only support an url
      if self[:adapter] && self[:adapter] =~ /^(jdbc|do):/
        params = {}
        each_pair do |k, v|
          next if [:adapter, :host, :port, :database].include?(k)
          params[k] = v
        end
        params_str = params.each_pair{ |k, v| "#{k}=#{v}" }
        port = self[:port] ? ":#{self[:port]}" : ""
        self[:url] = "%s://%s%s/%s?%s" % [self[:adapter], self[:host], port, self[:database], params_str]
      end
    end
  end
end
