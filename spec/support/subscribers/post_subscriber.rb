class PostSubscriber < ::ActivePubsub::Subscriber

  observes "test.post"
  as "test"

  # Pointless as examples, but being used for integration testing

  on :created do
    author_post_report.increment!(:post_count) if record.has_key?(:author_id)
  end

  on :updated do
    author.last_name = "author_#{record[:author_id]}"
    author.save
  end

  on :destroyed do
    author_post_report.destroy
  end

  private

  def author
    @author ||= ::Fake::Blog::Author.find(record[:author_id])
  end

  def author_post_report
    @author_post_report ||= ::Fake::Blog::AuthorPostReport.where(:author_id => record[:author_id]).first_or_create
  end
end
