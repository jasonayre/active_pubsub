module ActivePubsub
  module PublishWithSerializer
    extend ActiveSupport::Concern

    #todo: move this into separate gem

    included do
      class_attribute :publish_serializer
    end

    def serialized_resource
       serialized_resource_attributes = self.class.publish_serializer.new(self).attributes
       serialized_resource_attributes.merge!("changes" => changes) if self.changed?
      ::Marshal.dump(serialized_resource_attributes)
    end

    module ClassMethods
      def serialize_publish_with(klass)
        self.publish_serializer = klass
      end
    end
  end
end
