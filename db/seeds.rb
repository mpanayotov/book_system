if Rails.env == 'development'
  user = User.create name: 'Mihail'

  # create 5 authors
  authors = {}
  %w(Peter John Daniel Luke Vincent).each_with_index do |name, i|
    authors[i] = Author.create name: name
  end

  # create 15 books, 3 books per author
  books = {}
  (0..14).each do |i|
    books[i] = Book.create title: "Book#{i+1}", author: authors[i%5], genres: ['drama', 'comedy']
  end

  # upvote first five books starting from second one
  (1..5).each { |i| Upvote.create user: user, book: books[i] }

  # follow first two authors
  (0..1).each { |i| Follow.create user: user, author: authors[i] }
end