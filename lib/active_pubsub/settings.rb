module ActivePubsub
  module Settings
    extend ::ActiveSupport::Concern

    def exchange_settings
      self.class.exchange_settings
    end

    def queue_settings
      self.class.queue_settings
    end

    def subscribe_settings
      self.class.subscribe_settings
    end

    module ClassMethods
      def exchange_settings
        {
          :durable => ::ActivePubsub.config.durable,
          :auto_delete => !::ActivePubsub.config.durable
        }
      end

      def queue_settings
        {
          :manual_ack => ::ActivePubsub.config.ack,
          :durable => ::ActivePubsub.config.durable
        }
      end

      def subscribe_settings
        {
          :manual_ack => ::ActivePubsub.config.ack,
          :block => false
        }
      end
    end
  end
end
