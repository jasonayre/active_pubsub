require 'spec_helper'

describe ActivePubsub::Subscriber do

  subject { ::PostSubscriber }

  its(:events) { should have_key(:created) }
  its(:events) { should have_key(:destroyed) }
  its(:exchange_name) { should eq "test.post" }
  its(:local_service_namespace) { should eq "test" }
  its(:started) { should be true }
  its(:connection) { should be_a(ActivePubsub::Connection) }

  describe ".on" do
    context "created" do
      let!(:fake_author) { ::Fake::Blog::Author.create!(:first_name => "Samir", :last_name => "Nyininejad") }
      let!(:fake_post) { ::Fake::Blog::Post.create!(:title => "myblogpost", :author_id => fake_author.id) }

      it "should increment post_count" do
        sleep(0.1)
        ::Fake::Blog::AuthorPostReport.find_by(:author_id => fake_author.id).post_count.should eq 1
      end
    end
  end
end
