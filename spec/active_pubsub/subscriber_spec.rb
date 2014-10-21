require 'spec_helper'

describe ActivePubsub::Subscriber do

  subject { ::PostSubscriber }

  its(:events) { should have_key(:created) }
  its(:events) { should have_key(:destroyed) }
  its(:events) { should have_key(:updated) }
  its(:exchange_name) { should eq "test.post" }
  its(:local_service_namespace) { should eq "test" }
  its(:started) { should be true }
  its(:connection) { should be_a(ActivePubsub::Connection) }

  describe ".on" do
    context ":created" do
      let!(:fake_author) { ::Fake::Blog::Author.create!(:first_name => "Samir", :last_name => "Nyininejad") }
      let!(:fake_post) { ::Fake::Blog::Post.create!(:title => "myblogpost", :author_id => fake_author.id) }

      it "should increment post_count" do
        sleep(0.1)
        ::Fake::Blog::AuthorPostReport.find_by(:author_id => fake_author.id).post_count.should eq 1
      end
    end

    context ":destroyed" do
      let!(:fake_author) { ::Fake::Blog::Author.create!(:first_name => "Samir", :last_name => "Nyininejad") }
      let!(:fake_post) { ::Fake::Blog::Post.create!(:title => "myblogpost", :author_id => fake_author.id) }

      it "should destroy author post report" do
        fake_post.destroy
        sleep(0.1)
        ::Fake::Blog::AuthorPostReport.where(:author_id => fake_author.id).first.should be_nil
      end
    end

    context ":updated" do
      let!(:fake_author) { ::Fake::Blog::Author.create!(:first_name => "Samir", :last_name => "Nyininejad") }
      let!(:fake_post) { ::Fake::Blog::Post.create!(:title => "myblogpost", :author_id => fake_author.id) }

      it "should update author last name with author_id" do
        fake_post.title = "Asdfg"
        fake_post.save

        sleep(0.1)

        fake_author.reload.last_name.should eq "author_#{fake_author.id}"
      end
    end
  end
end
