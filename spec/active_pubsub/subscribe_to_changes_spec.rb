require 'spec_helper'
require 'support/subscribers/author_subscriber'

describe ::ActivePubsub::SubscribeToChanges do
  before do
    ::ActivePubsub.start_subscribers
  end

  subject { ::AuthorSubscriber }

  let(:fake_author) { ::Fake::Blog::Author.create!(:first_name => "Bill", :last_name => "Lumberg") }
  let(:fake_post) { ::Fake::Blog::Post.create!(:title => "Fake post by #{fake_author.first_name}", :author_id => fake_author.id) }

  its(:attributes_to_watch_for_changes) {
    should have_key(:first_name)
  }

  describe "#on_change" do
    context "when author last name is changed" do
      it "does not update titles" do
        fake_post

        fake_author.last_name = "Bolton"
        fake_author.save

        fake_author.posts.last.title.should eq "Fake post by Bill"
      end
    end

    context "when author first name is changed" do
      # ghetto, but since its async we need to sleep to see update
      it "updates all titles with new author name" do
        fake_post

        fake_author.first_name = "Michael"
        fake_author.save
        sleep(0.5)
        fake_author.posts.last.title.should eq "Fake post by Michael"
      end
    end
  end
end
