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
      each_pair do |k, v|
        k = k.to_sym
        case k
          when :uri
            self[:url] = delete(:uri)
          when :adapter
            v = v.to_sym
            case v
              when :sqlite3
                self[k] = :sqlite
              when :postgresql
                self[k] = :postgres
            end
        end
      end

      # always use jdbc when running jruby
      if defined?(JRUBY_VERSION)
        self[:adapter] = "jdbc:#{self[:adapter]}"
      end
      
      # some adapters only support an url
      if self[:adapter] =~ "^(jdbc|do):"
        port = self[:port] ? ":#{self[:port]}" : ""
        params = {}
        each_pair do |k, v|
          next if [].include?(:adapter, :host, :port, :database)
          params[k] = v
        end
        self[:url] = "%s://%s%s/%s?%s" % [self[:adapter], self[:host], port, self[:database], params]
      end
    end
  end
end
