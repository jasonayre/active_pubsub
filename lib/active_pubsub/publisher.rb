module ActivePubsub
  class Publisher
    include ::ActivePubsub::Settings
    include ::Celluloid

    attr_accessor :connection
    finalizer :clear_connections!

    ### Class Methods ###
    class << self
      attr_accessor :started
      attr_accessor :publishable_model_count
    end

    @started = false
    @publishable_model_count = 0

    def self.increment_publishable_model_count!
      self.publishable_model_count += 1
    end

    def self.start
      supervise_as :rabbit_publisher

      self.started = true
    end

    def self.started?
      self.started
    end

    ### Instance Methods ###
    def initialize
      connection
    end

    def connection
      @connection ||= ::ActivePubsub::Connection.new
    end

    def clear_connections!
      channel.close
      connection.close
    end

    def channel
      connection.channel
    end

    def exchanges
      @exchanges ||= {}
    end

    def options_for_publish(event)
      {
        :routing_key => event.routing_key,
        :persistent => ::ActivePubsub.config.durable
      }
    end

    def publish_event(event)
      return if ::ActivePubsub.publisher_disabled?

      ::ActiveRecord::Base.connection_pool.with_connection do
        ::ActivePubsub.logger.info("Publishing event: #{event.id} to #{event.routing_key}")

        exchanges[event.exchange].publish(serialize_event(event), options_for_publish(event))
      end
    end

    def serialize_event(event)
      ::Marshal.dump(event)
    end

    def register_exchange(exchange_name)
      exchanges[exchange_name] ||= channel.topic(exchange_name, exchange_settings)
    end
  end
end
