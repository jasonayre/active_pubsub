module ActivePubsub
  module SubscribeToChanges
    extend ActiveSupport::Concern

    included do
      class_attribute :attributes_to_watch_for_changes
      self.attributes_to_watch_for_changes = {}

      on :updated do |changed_record|
        attributes_to_watch_for_changes.each_pair do |field, block|
          if changed_record[:changes].with_indifferent_access.has_key?(field)
            old_value = changed_record[:changes][field][0]
            new_value = changed_record[:changes][field][1]
            instance_exec(new_value, old_value, &block)
          end
        end
      end
    end

    module ClassMethods
      def on_change(attribute_name, &block)
        attributes_to_watch_for_changes[attribute_name] = block
      end
    end
  end
end
