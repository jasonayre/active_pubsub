module ActivePubsub
  module Publishable
    extend ActiveSupport::Concern

    PUBLISHABLE_ACTIONS = ["updated", "created", "destroyed"]

    included do
      include ::ActiveModel::Dirty

      after_create :publish_created_event
      after_update :publish_updated_event
      after_destroy :publish_destroyed_event
      class_attribute :exchange_prefix

      self.publishable_actions ||= []

      ::ActivePubsub::Publisher.increment_publishable_model_count!
    end

    def attributes_hash
      attributes.merge!("changes" => changes)
    end

    private

    def publish_updated_event
      record_updated_event = ::ActivePubsub::Event.new(self.class.exchange_key, "updated", serialized_resource)

      ::ActivePubsub.publish_event(record_updated_event)
    end

    def publish_created_event
      record_created_event = ::ActivePubsub::Event.new(self.class.exchange_key, "created", serialized_resource)

      ::ActivePubsub.publish_event(record_created_event)
    end

    def publish_destroyed_event
      record_destroyed_event = ::ActivePubsub::Event.new(self.class.exchange_key, "destroyed", serialized_resource)

      ::ActivePubsub.publish_event(record_destroyed_event)
    end

    def serialized_resource
      Marshal.dump(attributes_hash)
    end

    module ClassMethods
      def exchange_key
        [
          try(:exchange_prefix) { ::ActivePubsub.config.try(:publish_as) },
          name.demodulize.underscore
        ].flatten.compact.join(".")
      end

      #this is the publishing service namespace which will be used to build exchange name

      def publish_as(prefix)
        self.exchange_prefix = prefix

        ::ActivePubsub::Publisher.start unless ::ActivePubsub::Publisher.started

        ::ActivePubsub.publisher.register_exchange(exchange_key)
      end

      #todo: make publishable actions filterable/appendable
      def publishable_actions(*actions)
        @publishable_actions = actions
      end

      def routing_key
        resource_routing_keys.join(".")
      end

      def resource_routing_keys
        [try(:exchange_prefix), name.demodulize.underscore].flatten.compact
      end
    end
  end
end
