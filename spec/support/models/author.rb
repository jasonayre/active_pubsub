require 'active_record'
require_relative '../../support/serializers/author_serializer.rb'
module Fake
  module Blog
    class Author < ::ActiveRecord::Base
      include ::ActivePubsub::Publishable
      include ::ActivePubsub::PublishWithSerializer

      serialize_publish_with ::AuthorSerializer

      publish_as "test"

      has_many :posts, :class_name => "Fake::Blog::Post"
    end
  end
end
