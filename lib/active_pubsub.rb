require "active_pubsub/version"

ENV['RABBITMQ_URL'] ||= "amqp://guest:guest@localhost:5672"

require "bunny"
require "celluloid"
require "active_support/all"
require "active_attr"
require "pry"
require "active_pubsub/config"
require "active_pubsub/logging"
require "active_pubsub/settings"

module ActivePubsub
  class << self
    attr_accessor :configuration
    alias_method :config, :configuration

    delegate :publish_event, :to => :publisher
  end

  @configuration ||= ::ActivePubsub::Config.new

  def self.configure
    yield(configuration)

    ::ActiveSupport.run_load_hooks(:active_pubsub, self)
  end

  def self.disable_publisher!
    configuration.disable_publisher = true
  end

  def self.load_subscribers
    ::Dir.glob(::Rails.root.join('app', 'subscribers', "*.rb")).each{ |file| load file }
  end

  def self.logger
    configuration.logger
  end

  def self.logger?
    configuration.logger.present?
  end

  def self.publisher
    ::Celluloid::Actor[:rabbit_publisher]
  end

  def self.publisher_disabled?
    configuration.publisher_disabled
  end

  def self.start_publisher
    ::ActivePubsub::Publisher.start unless ::ActivePubsub::Publisher.started?
  end

  def self.start_subscribers
    ::ActivePubsub::Subscriber.subclasses.each do |subscriber|
      next if subscriber.started?

      ::ActivePubsub.logger.info("Starting #{subscriber.name}")

      subscriber.bind_subscriptions!
      subscriber.print_subscriptions!
    end
  end

  def self.symbolize_routing_key(routing_key)
    :"#{routing_key.split('.').join('_')}"
  end
end

require "active_pubsub/connection"
require "active_pubsub/event"
require "active_pubsub/publisher"
require "active_pubsub/publishable"
require "active_pubsub/publish_with_serializer"
require "active_pubsub/subscriber"
require "active_pubsub/subscribe_to_changes"
require 'active_pubsub/railtie' if defined?(Rails)
