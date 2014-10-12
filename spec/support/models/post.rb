require 'active_record'
module Fake
  module Blog
    class Post < ::ActiveRecord::Base
      include ::ActivePubsub::Publishable

      publish_as "test"
    end
  end
end
