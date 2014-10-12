# this is an example of a service that wants to do something when posts are created,
# updated, or destroyed, in the publishing service

class PostSubscriber < ::ActivePubsub::Subscriber
  observes "cms"
  as "aggregator"

  on :created do |record|
    puts record.inspect
  end

  on :destroyed do |record|
    puts record.inspect
  end

  on :updated do |record|
    puts record.inspect
  end
end
