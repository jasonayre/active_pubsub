require 'spec_helper'

describe ::ActivePubsub::PublishWithSerializer do
  subject { ::Fake::Blog::Author }
  let(:publisher) { ::ActivePubsub.publisher }

  context "ClassMethods" do
    its(:publish_serializer) { should eq ::AuthorSerializer }
  end

  context "InstanceMethods" do
    subject{ ::Fake::Blog::Author.new(:first_name => "whatever") }

    its (:serialized_resource_attributes) { should have_key(:first_name) }

    describe "#serialized_resource" do
      it "should dump serialized resource attributes" do
        Marshal.should_receive(:dump).with(subject.serialized_resource_attributes)

        subject.serialized_resource
      end
    end
  end
end
