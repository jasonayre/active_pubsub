class AuthorSubscriber < ::ActivePubsub::Subscriber
  include ::ActivePubsub::SubscribeToChanges

  observes "test.author"
  as "test"

  on_change :first_name do |new_value, old_value|
    author.posts.update_all(:title => "Fake post by #{new_value}")
  end

  private

  def author
    @author ||= ::Fake::Blog::Author.find(record[:id])
  end
end
