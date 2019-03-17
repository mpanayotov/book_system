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

  def book
    Book.arel_table
  end

  def upvoted_books
    Book.joins(:upvotes)
        .joins(:author)
        .where(upvotes: { user: user })
  end

  def followed_authors_books
    Author.joins(:follows)
          .joins(:books)
          .where(follows: { user: user })
  end

  def prioritized_books
    return @prioritized_books if @prioritized_books
    upvoted_and_followed = upvoted_books.where(id: followed_authors_books.select(book[:id]))
    only_upvoted = upvoted_books.where.not(id: followed_authors_books.select(book[:id]))
    union = upvoted_and_followed.union(only_upvoted)
    @prioritized_books = Book.from(book.create_table_alias(union, :books)).load
  end
end
