class BookRecommendationGenerator
  def initialize(books, recommendations=5)
    @books = books
    @recommendations = recommendations
  end

  def call
    recommended_books = books.present? ? based_on_user_history : []

    (recommendations - recommended_books.count).tap do |left|
      recommended_books << based_on_general_trend(left, recommended_books.map(&:id)) if left > 0
    end
  
    recommended_books.flatten
  end

  private

  attr_reader :books, :recommendations

  def based_on_user_history
    Book.most_upvoted
        .where(author_id: author_ids)
        .where.not(id: book_ids)
        .where("JSON_CONTAINS(genres, :genre)", genre: "[\"#{favourite_genre}\"]")
        .limit(recommendations)
        .sort_by { |book| author_ids.index(book.author_id) }
  end

  def based_on_general_trend(limit, exclude_ids)
    scope = Book.most_upvoted
    scope = scope.where("JSON_CONTAINS(genres, :genre)", genre: "[\"#{favourite_genre}\"]") if favourite_genre.present?
    scope = scope.where.not(id: exclude_ids) if exclude_ids.present?
    scope.limit(limit)
  end

  def favourite_genre
    @favourite_genre ||= books.map { |book| book['genres'] }
                              .flatten
                              .group_by(&:to_s)
                              .max_by { |_,v| v.count }
                              &.first
  end

  def author_ids
    books.map { |book| book['author_id'] }.uniq
  end

  def book_ids
    books.map { |book| book['id'] }
  end
end
