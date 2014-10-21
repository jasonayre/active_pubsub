module ActivePubsub
  module PublishWithSerializer
    extend ActiveSupport::Concern

    #todo: move this into separate gem?

    included do
      class_attribute :publish_serializer
    end

    def serialized_resource
      serialized_resource_attributes.merge!(:changes => previous_changes) if previous_changes

      ::Marshal.dump(serialized_resource_attributes)
    end

    def serialized_resource_attributes
       @serialized_resource_attributes ||= self.class
                                               .publish_serializer.new(self)
                                               .attributes
                                               .symbolize_keys!
    end

    module ClassMethods
      def serialize_publish_with(klass)
        self.publish_serializer = klass
      end
    end
  end
end
