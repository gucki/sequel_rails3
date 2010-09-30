require 'sequel'
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

      self.db = Sequel.connect(config)
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
  end
end
