Notes:
I created a rails app with mysql(8.0.13) and worked with ActiveRecord as it feels a bit more natural to me that way. Implemented classes are covered with rspec(used [FactoryBot](https://github.com/thoughtbot/factory_bot) along with Faker), so to run tests:

        bundle exec rspec -fd

Factories and specs are in `spec` folder

#### Feed generator

My feed generator returns a list of the books the user has upvoted by giving priority to the upvoted books whose authors are followed as well, as that way the ones on top of the feed(first in the list) will be the books that are most appealing to the reader (assuming that if he/she likes a book as well as its author, that book is more appealing/interesting to him/her than a book with no particular expressed interest in its author).
Implementaion:
        app/services/feed.rb
Tests:
        spec/services/feed_spec.rb


#### Payment Factory design

All files related to the design are in `lib/payment_processing` folder.
`lib/payment_processing/payment_factory.rb` is a good starting point. It serves as the api that provides a flexible way for adding payment adapters.

#### Recommendation system

With having genres for each book, in order to find the most suitable ones based on a list of books we should:
- look for books of same authors
- check for most common genre
- check for the number of upvotes
My logic dictates that if I like three history books of Author A, I would probably fancy another history book of the same author. And if the fourth history book of A is the top voted all A's history books(excluding first three) that makes it most relevant for recommendation (based_on_user_history). If there is not relevant books of same authors, it makes most sense to me to start filling the recommendations list with most upvoted ones in general that match most common genre if such exists. Assumption here is that the reader will like same books that are already most popular (based_on_general_trend).

Implementation:
        app/services/book_recommendation_generator.rb
Tests:
        spec/services/book_recommendation_generator_spec.rb

With this approach we are trying to predict most suitable books(based on a list of books) based on information we already have in db for our readers, hence creating the recommendation list is a purely computational task. As db records will grow, processing the information might take more time and from design point of view it is best to isolate that computation. Therefore, I created a [Resque](https://github.com/resque/resque) job, that would build the recommendation list for a user and save it in BookRecommendation model which should serve as our cache table.

Implementation:
        app/jobs/book_recommendation_updater_job.rb
Test:
        spec/jobs/book_recommendation_updater_job_spec.rb

That way we can easily recalculate the recommendation list for a user when most suitable.

If we want to create machine learning classifier algorithm (with TensorFlow for example), build models and create user features and then make decisions based on those then it might be most efficient to create a seperate service that takes care of building the user recommendations.