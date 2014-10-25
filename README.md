# ActivePubsub

Service oriented observers for active record, via RabbitMQ and Bunny gem. Publish/Observe changes made to ActiveRecord models asynchronously, from different applications/services.

Best examples can be found here:
https://github.com/jasonayre/active_pubsub_examples

### Quick important development/spring bug note ###
If you are having issues with either publisher or subscribers hanging in development,
kill spring. Kill it twice actually. Make sure its dead. Then restart with env var

```
DISABLE_SPRING=1 bx subscriber start
```

And when running server or console make sure to DISABLE_SPRING=1 as well. (dont know how to treat the problem yet just diagnose the symptom which seems to be spring)

## Publisher Example
``` ruby
class Post < ::ActiveRecord::Base
  include ::ActivePubsub::Publishable

  # This is the namespace for the local service
  # The following Will set up a cms.post rabbit exchange
  publish_as "cms"
end
```

## Subscriber example
``` ruby
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
```

### Subscribe to individual attribute changes

``` ruby
class PostSubscriber < ::ActivePubsub::Subscriber
  include ::ActivePubsub::SubscribeToChanges

  # Note: Do NOT define updated as an event, as on_change
  # uses updated event so latter event will override former
  observes "cms"
  as "aggregator"

  on_change :title do |new_value, old_value|
    puts record.inspect
    puts new_value
  end
end
```

## Publishing events

Just include ::ActivePubsub::Publishable module into an active record class whose events you want to publish.

``` ruby
class Post < ::ActiveRecord::Base
  include ::ActivePubsub::Publishable
end
```

Also, you need to declare a namespace to publish under, either in the main configuration or in the model

``` ruby
class Post < ::ActiveRecord::Base
  include ::ActivePubsub::Publishable
  publish_as "cms"
end
```

Or in initializer

``` ruby
::ActivePubsub.configure do |config|
  config.publish_as = "cms"
end
```

**IMPORTANT:** If you don't do one of the above the publisher will not be started.

The publisher simply runs in a new thread alongside your main application, connects to rabbit, and publishes the events.

## Subscribing to Events

Subscriber runs in a separate process from your application itself. You can start the subscriber with:

## Starting the subscriber

```
bundle exec subscriber start
```

## Benchmarks/Performance

No full benchmarks, but here are the results Ive seen so far via rabbit. MacbookPro, 2.6 i7 w 16gb ram. Running one publisher app and one subscriber, via examples at https://github.com/jasonayre/active_pubsub_examples

### Celluloid version > 0.16

I removed the gem lock to be compatibile with the most recent version of sidekiq which uses celluloid (0.15.2) or something, however I noticed a significant speed boost with > 0.16 version of celluloid.

Range of published messages/second: 250-500
Range processed (subscriber) messages/second: 250-500

### Celluloid version 15.2

Average published messages/second: 100-150
Average processed (subscriber) messages/second: 100-150

The throughput seems to be limited by the publisher mostly, from the very limited benchmarks thus far.

### Connecting to rabbit

If you are running rabbit at different address or port, set address via ENV variable, i.e.

```
RABBITMQ_URL=amqp://guest:guest@x.x.x.x:XXXX bundle exec subscriber start
```

Or you can set via config

``` ruby
::ActivePubsub.configure do |config|
  config.address = "amqp://guest:guest@x.x.x.x:XXXX"
end
```

Its still really early in development cycle, so there may be issues running tests if you aren't running rabbit. Should probably fix that.

### Installation

Add this line to your application's Gemfile:

    gem 'active_pubsub'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_pubsub



## Contributing

1. Fork it ( https://github.com/[my-github-username]/active_pubsub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
