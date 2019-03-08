class Feed
  def initialize(user)
    @user = user
  end

  def retrieve
    prioritized_books
  end

  def refresh
    return prioritized_books unless @prioritized_books
    upvoted_books - prioritized_books
  end

  private

  attr_reader :user

  def upvoted_books
    Book.joins(:upvotes)
        .joins(:author)
        .select(book_feed_fields)
        .where(upvotes: { user: user })
        .map(&:attributes)
  end

  def followed_authors_books
    Author.joins(:follows)
          .joins(:books)
          .select(book_feed_fields)
          .where(follows: { user: user })
          .map(&:attributes)
          .map { |book| book.merge({'genres'=> JSON.parse(book['genres'])}) }
  end

  def book_feed_fields
    'authors.name as author_name, authors.id as author_id, books.*'
  end

  def prioritized_books
    return @prioritized_books if @prioritized_books

    upvoted = upvoted_books
    upvoted_and_followed_author = upvoted & followed_authors_books
    only_upvoted = upvoted - upvoted_and_followed_author

    @prioritized_books = [upvoted_and_followed_author, only_upvoted].flatten
  end
end
