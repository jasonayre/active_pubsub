require 'active_support/ordered_options'

module ActivePubsub
  ### IMPORTANT ###
  # Set service namespace if your subscriber has namespace set or it wont get events"
  class Config < ::ActiveSupport::OrderedOptions
    def initialize(options = {})
      options[:address] = ENV['RABBITMQ_URL']
      options[:publish_as] = nil
      options[:service_namespace] = nil
      super
    end
  end
end
