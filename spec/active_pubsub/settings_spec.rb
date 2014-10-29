require 'spec_helper'

describe ::ActivePubsub::Settings do
  subject {
    class FakeSettingsIncluder
      include ::ActivePubsub::Settings
    end
  }

  its(:exchange_settings) {
    options = { :durable => false, :auto_delete => true }
    should eq options
  }

  its(:queue_settings) {
    options = { :manual_ack => false, :durable => false }
    should eq options
  }

  its(:subscribe_settings) {
    options = { :manual_ack => false, :block => false }
    should eq options
  }

  context "acknowledgement is true" do
    before do
      ::ActivePubsub::Config.any_instance.stub(:ack).and_return(true)
    end

    its(:queue_settings) {
      options = { :manual_ack => true, :durable => false }
      should eq options
    }

    its(:subscribe_settings) {
      options = { :manual_ack => true, :block => false }
      should eq options
    }
  end

  context "durability is true" do
    its(:exchange_settings) {
      options = { :durable => false, :auto_delete => true }
      should eq options
    }

    its(:queue_settings) {
      options = { :manual_ack => false, :durable => false }
      should eq options
    }

    its(:subscribe_settings) {
      options = { :manual_ack => false, :block => false }
      should eq options
    }
  end
end
