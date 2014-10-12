require 'active_support/all'

module ActivePubsub
  class Subscriber
    attr_accessor :connection

    class_attribute :events
    class_attribute :exchange_name
    class_attribute :connection
    class_attribute :local_service_namespace

    self.events = {}
    self.connection = ::ActivePubsub::Connection.new

    ### Class Methods ###
    def self.channel
      connection.channel
    end

    def self.exchange
      channel.topic(exchange_name, :auto_delete => true)
    end

    def self.as(service_namespace)
      self.local_service_namespace = service_namespace
    end

    def self.on(event_name, &block)
      events[event_name] = block
    end

    def self.bind_subscriptions!
      events.each_pair do |event_name, block|
        channel.queue(queue_for_event(event_name.to_s))
               .bind(exchange, :routing_key => routing_key_for_event(event_name))
               .subscribe do |delivery_info, properties, payload|
          event = deserialize_event(payload)
          resource = deserialize_record(event[:record])

          block.call(resource)
        end
      end
    end

    def self.deserialize_event(event)
      @current_event = Marshal.load(event)
    end

    def self.deserialize_record(record)
      @current_record = Marshal.load(record)
    end

    def self.observes(target_exchange)
      self.exchange_name = target_exchange
    end

    def self.queue_for_event(event_name)
      [local_service_namespace, exchange_name, event_name].compact.join('.')
    end

    def self.routing_key_for_event(event_name)
      [exchange_name, event_name].join(".")
    end

    def self.print_subscriptions!
      message = "Watching: \n"
      events.each_pair do |event_name, block|
        message << "Queue: #{queue_for_event(event_name.to_s)} \n" <<
                   "Routing Key: #{routing_key_for_event(event_name)} \n" <<
                   "\n"
      end

      puts message
    end
  end
end
