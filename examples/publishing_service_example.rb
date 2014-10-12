class Post < ::ActiveRecord::Base
  include ::ActivePubsub::Publishable

  # This is the namespace for the local service
  # The following Will set up a cms.post rabbit exchange
  publish_as "cms"
end
