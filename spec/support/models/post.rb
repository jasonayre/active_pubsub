require 'active_record'
module Fake
  module Blog
    class Post < ::ActiveRecord::Base
      include ::ActivePubsub::Publishable

      publish_as "test"

      belongs_to :author, :class_name => "Fake::Blog::Author"
    end
  end
end
