require 'spec_helper'

describe ::ActivePubsub::Publishable do
  subject { ::Fake::Blog::Post }
  let(:instance_subject) { ::Fake::Blog::Post.new }
  let(:publisher) { ::ActivePubsub.publisher }

  context "when included" do
    it "should increment publishable model count on publisher class" do
      expect(::ActivePubsub::Publisher.publishable_model_count).to be > 0
    end

    context "Instance Methods" do
      describe "#attributes_hash" do
        #had to do some hackyness in attributes_hash method to get this to pass
        #and not sure why, but as_json was coming back nil
        it "should call as json" do
          instance_subject.should_receive(:as_json)

          instance_subject.attributes_hash
        end

        context "when attributes are changed" do
          let(:created_record) { ::Fake::Blog::Post.create!(:title => "Post about nothing") }

          it "should merge previous changes" do
            expect(created_record.attributes_hash).to have_key(:title)
          end
        end
      end

      describe "#publish_updated_event" do
        let(:created_record) { ::Fake::Blog::Post.create!(:title => "Post about nothing") }

        it "should build updated action event when record is updated" do
          ::ActivePubsub.should_receive(:publish_event).with(instance_of(::ActivePubsub::Event)).once
          created_record
        end
      end

      describe "#publish_created_event" do
        let(:created_record) { ::Fake::Blog::Post.create!(:title => "Post about nothing") }

        it "should publish when record is updated" do
          ::ActivePubsub.should_receive(:publish_event).with(instance_of(::ActivePubsub::Event)).twice

          created_record
          created_record.title = "asdasd"
          created_record.save
        end
      end

      describe "#publish_destroyed_event" do
        let(:created_record) { ::Fake::Blog::Post.create!(:title => "Post about nothing") }

        it "should publish when record is updated" do
          ::ActivePubsub.should_receive(:publish_event).with(instance_of(::ActivePubsub::Event)).twice

          created_record.destroy
        end
      end
    end

    context "Class Methods" do
      its(:exchange_key) { should eq "test.post" }
    end
  end
end
