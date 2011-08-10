require 'sequel'
require 'sequel/model'
require 'rails'
require 'sequel_rails3/configuration'
require 'sequel_rails3/logger'

module SequelRails3
  class Railtie < Rails::Railtie
    cattr_accessor :db
    cattr_accessor :config

    initializer 'sequel_rails3.init', :before => :load_environment_config do |app|
      self.config = Configuration.new(app)
      self.config.normalize!

      Sequel::Model.raise_on_save_failure = false
      Sequel::Model.raise_on_typecast_failure = false

      Sequel::Model.plugin :active_model

      self.db = config[:url] ? Sequel.connect(config[:url], config) : Sequel.connect(config)
    end

    initializer 'sequel_rails3.logging', :after => :initialize_logger do |app|
      SequelRails3::Logger.logger = Rails.logger
    end

    initializer 'sequel_rails3.log_runtime' do |app|
      require 'sequel_rails3/railties/controller_runtime'
      ActiveSupport.on_load(:action_controller) do
        include SequelRails3::Railties::ControllerRuntime
      end
    end

    def self.migrator
      Sequel::IntegerMigrator.new(db, File.join(Rails.root, 'db', 'migrate'))
    end

    def self.migrate_to(version)
      Sequel::IntegerMigrator.apply(db, File.join(Rails.root, 'db', 'migrate'), version)
    end

    def self.schema(action)
      case action
        when :dump
          File.open(schema_file, "w") do |f|
            f.write("# Database schema version: #{migrator.current}\n")
            f.write(db.dump_schema_migration)
          end
        when :up
          migration, version = read_schema
          eval(migration).apply(db, :up)
          db[:schema_info].insert(:version => version)
        when :down
          migration, version = read_schema
          db_version = db[:schema_info].select(:version).first.try(:[], :version)
          raise RuntimeError, "schema version in schema file (#{version}) differs from version in database (#{db_version})" unless version == db_version
          eval(migration).apply(db, :down)
        else
          raise ArgumentError, "invalid schema action '#{action}'"
      end
    end

    def self.schema_file
      File.join(Rails.root, 'db', 'schema.rb')
    end

    def self.read_schema
      data = File.read(schema_file)
      version = data.match(/# Database schema version: (\d+)\n/)[1]
      raise RuntimeError, "unable to determine schema version from schema file" unless version
      [data, version.to_i]
    end
  end
end

