require 'spec_helper'

describe ::ActivePubsub::Config do
  let(:address) { "somewhere" }
  let(:publish_as) { "my_namespace" }
  let(:service_namespace) { "my_service_namespace"}
  subject { described_class.new(:publish_as => publish_as, :address => address, :service_namespace => service_namespace) }

  its(:publish_as) { should eq publish_as }
  its(:address) { should eq address}
  its(:service_namespace) { should eq service_namespace }

  context "defaults" do
    subject { described_class.new }
    its(:address) { should eq ENV["RABBITMQ_URL"] }
    its(:publish_as) { should eq nil }
    its(:service_namespace) { should eq nil }
    its(:ack) { should be false }
    its(:durable) { should be false }
    its(:logger) { should be_instance_of(::Logger) }
    its(:publisher_disabled) { should eq false }
  end

end
