require "bunny"

module ActivePubsub
  class Connection < Delegator
    attr_accessor :connection, :channel

    def initialize(options = {})
      @connection = ::Bunny.new(::ActivePubsub.config.try(:address) || ENV["RABBITMQ_URL"])
      @connection.start
      @channel = connection.create_channel
    end

    def __getobj__
      @connection
    end
  end
end
