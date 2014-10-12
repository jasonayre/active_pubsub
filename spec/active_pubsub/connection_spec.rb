require 'spec_helper'

describe ::ActivePubsub::Connection do
  subject { described_class.new }

  its(:connection) { should be_an_instance_of(::Bunny::Session) }
  its(:channel) { should be_a(::Bunny::Channel) }
end
