module ActivePubsub
  class Publisher
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

    def publish_event(event)
      ::ActiveRecord::Base.connection_pool.with_connection do
        exchanges[event.exchange].publish(serialize_event(event), :routing_key => event.routing_key)
      end
    end

    def serialize_event(event)
      ::Marshal.dump(event)
    end

    def register_exchange(exchange_name)
      exchanges[exchange_name] ||= channel.topic(exchange_name, :auto_delete => true)
    end
  end
end
