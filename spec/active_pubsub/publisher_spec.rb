require 'spec_helper'

describe ::ActivePubsub::Publisher do
  let(:fake_record) { ::Fake::Blog::Post.new }
  let(:exchange_key) { "test.post" }
  let(:event_name) { "test.post.created" }
  let(:routing_key) { "test.post.created" }
  let(:record_created_routing_key) { "test.post.created" }
  let(:record_updated_routing_key) { "test.post.updated" }
  let(:record_destroyed_routing_key) { "test.post.destroyed" }

  let(:fake_event) {
    ::ActivePubsub::Event.new(routing_key, event_name, fake_record)
  }

  subject {
    ::Celluloid::Actor[:rabbit_publisher]
  }

  describe "#connection" do
    it "should be active pubsub connection instance" do
      subject.connection.should be_a(ActivePubsub::Connection)
    end
  end

  describe "#clear_connections!" do
    # todo: fix this test, it was causing strange network failure error
    # it "should close channel" do
    #   subject.should_receive(:channel)
    #   subject.stub_chain(:channel, :close)
    #   subject.stub_chain(:connection, :close)
    #
    #   subject.clear_connections!
    # end
    #
    # it "should close connection" do
    #   subject.should_receive(:connection)
    #   subject.stub_chain(:channel, :close)
    #   subject.stub_chain(:connection, :close)
    #
    #   subject.clear_connections!
    # end
  end

  describe "#exchanges" do
    its(:exchanges) { should include(exchange_key) }
  end

  describe "#options_for_publish" do
    let(:expected) {
      {
        :routing_key => fake_event.routing_key,
        :persistent => false
      }
    }

    it { subject.options_for_publish(fake_event).should eq expected }

    context "durable is true" do
      before do
        ::ActivePubsub::Config.any_instance.stub(:durable).and_return(true)
      end

      let(:expected) do
        {
          :routing_key => fake_event.routing_key,
          :persistent => true
        }
      end

      it { subject.options_for_publish(fake_event).should eq expected }
    end
  end

  describe "#publish_event" do
    it "should receive publish event with instance of event when publishable record is saved" do
      subject.should_receive(:publish_event).with(instance_of(::ActivePubsub::Event))

      fake_record.save
    end
  end
end
