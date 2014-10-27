require 'logger'

module ActivePubsub
  module Logging
    def self.initialize_logger(log_target=$stdout, log_level=::Logger::INFO)
      @counter ||= 0
      @counter = @counter + 1
      @logger = ::Logger.new(log_target)
      @logger.level = log_level
      @logger
    end

    def self.logger
      defined?(@logger) ? @logger : initialize_logger
    end

    def self.logger=(new_logger)
      @logger = new_logger
    end

    def logger
      ::ActivePubsub::Logging.logger
    end

    def log_exception(ex)
      logger.error { ex.message }
      logger.error { ex.backtrace[0..5].join("\n") }
      logger.debug { ex.backtrace.join("\n") }
    end

    def log_signature
      @_log_signature ||= "[#{self.class == Class ? self.name : self.class.name}]"
    end

    def sign_message(message)
      "#{log_signature} #{message}"
    end
  end
end

# Inspired by [protobuf](https://github.com/localshred/protobuf)
