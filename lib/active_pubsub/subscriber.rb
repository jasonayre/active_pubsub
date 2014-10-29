require 'active_support/all'

module ActivePubsub
  class Subscriber
    include ::ActivePubsub::Settings

    attr_accessor :connection

    class_attribute :events
    class_attribute :exchange_name
    class_attribute :connection
    class_attribute :local_service_namespace
    class_attribute :started

    self.connection = ::ActivePubsub::Connection.new
    self.started = false

    ### Class Methods ###
    def self.as(service_namespace)
      self.local_service_namespace = service_namespace
    end

    def self.clear_connections!
      channel.close
      connection.close
    end

    def self.channel
      connection.channel
    end

    def self.exchange
      channel.topic(exchange_name, exchange_settings)
    end

    def self.inherited(klass)
      klass.events = {}
    end

    def self.on(event_name, &block)
      events[event_name] = block
    end

    def self.bind_subscriptions!
      return if started?

      events.each_pair do |event_name, block|
        channel.queue(queue_for_event(event_name.to_s), queue_settings)
               .bind(exchange, :routing_key => routing_key_for_event(event_name))
               .subscribe(subscribe_settings) do |delivery_info, properties, payload|
          deserialized_event = deserialize_event(payload)
          deserialized_record = deserialize_record(deserialized_event[:record])

          subscriber_instance = new(deserialized_record)
          subscriber_instance.instance_exec(deserialized_record, &block)

          ::ActivePubsub.logger.info "#{delivery_info[:routing_key]} #{name} consumed #{deserialized_event}"

          channel.ack(delivery_info.delivery_tag) if ::ActivePubsub.config.ack
        end
      end

      self.started = true
    end

    def self.deserialize_event(event)
      ::Marshal.load(event)
    end

    def self.deserialize_record(record)
      ::Marshal.load(record)
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

      ::ActivePubsub.logger.info(message)
    end

    def self.started?
      self.started
    end

    ### Instance Methods ###
    attr_accessor :record

    def initialize(record)
      @record = record
    end
  end
end
