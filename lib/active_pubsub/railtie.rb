require 'rails/railtie'

module ActivePubsub
  class Railtie < ::Rails::Railtie
    # we only need publisher started if service has a publishable model
    ::ActiveSupport.on_load(:active_record) do
      puts "Active Record LOADED"

      if(::ActivePubsub::Publisher.publishable_model_count > 0) && !::ActivePubsub::Publisher.started?
        ::ActivePubsub::Publisher.start
      end
    end

    #todo: make redis configurable
    def self.load_config_yml
      config_file = ::YAML.load_file(config_yml_filepath)
      return unless config_file.is_a?(Hash)
    end

    def self.config_yml_exists?
      ::File.exists? config_yml_filepath
    end

    def self.config_yml_filepath
      ::Rails.root.join('config', 'rabbit.yml')
    end
  end
end
