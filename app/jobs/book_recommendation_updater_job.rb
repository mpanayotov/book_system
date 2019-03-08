class BookRecommendationUpdaterJob
  class << self
    def queue
      :recommendation_update
    end

    def perform(user_id)
      user = User.find(user_id)
      Rails.logger.info("Book recommendations for User:#{user_id} will be updated.")

      feed = Feed.new(user)
      recommended_books = BookRecommendationGenerator.new(feed.retrieve).call
      recommended_books_ids = recommended_books.map { |book| book['id'] }
      BookRecommendation.where(user: user_id)
                        .first_or_create!
                        .update(book_ids: recommended_books_ids)
    rescue => e
      Rails.logger.error("Updating book recommendations for User:#{user_id} failed with #{e.message}")
    end

    def enqueue!(user_id)
      Resque.enqueue self, user_id
    end
  end
end
