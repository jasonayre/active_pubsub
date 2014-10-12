require 'active_model'

module ActivePubsub
  class Event
    include ::ActiveAttr::Model
    include ::ActiveModel::AttributeMethods

    attribute :id
    attribute :exchange
    attribute :name
    attribute :occured_at
    attribute :record
    attribute :record_type
    attribute :routing_key

    #attributes have to be set for purposes of marshaling
    def initialize(exchange, name, record)
      self[:exchange] = exchange
      self[:name] = name
      self[:record] = record
      self[:id] = ::SecureRandom.hex
      self[:record_type] = record.class.name
      self[:occured_at] ||= ::DateTime.now
      self[:routing_key] ||= [exchange, name].join('.')
    end
  end
end
