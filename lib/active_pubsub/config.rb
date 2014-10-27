require 'active_support/ordered_options'

module ActivePubsub
  ### IMPORTANT ###
  # Set service namespace if your subscriber has namespace set or it wont get events"
  class Config < ::ActiveSupport::InheritableOptions
    def initialize(*args)
      super(*args)

      self[:address] ||= ENV['RABBITMQ_URL']
      self[:publish_as] ||= nil
      self[:service_namespace] ||= nil
      self[:logger] ||= ::ActivePubsub::Logging.logger
    end
  end
end
