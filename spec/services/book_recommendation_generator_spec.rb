require 'rails_helper'

describe BookRecommendationGenerator do
  let(:recommendations) { 3 }
  let(:authors) { create_list(:author, 3) }
  let(:book_set1) { create_list(:book, 3, author: authors[0], genres: ['comedy']) }
  let(:book_set2) { create_list(:book, 3, author: authors[1], genres: ['comedy']) }
  let(:book_set3) { create_list(:book, 3, author: authors[2], genres: ['comedy']) }
  
  describe '#call' do
    subject { described_class.new(books, recommendations).call }

    context 'without books for a base' do
      context 'without upvotes' do
        let(:books) { [] }

        it { is_expected.to be_empty }
      end

      context 'with many upvotes' do
        before do
          create(:upvote, book: book_set1.first)
          create_list(:upvote, 3, book: book_set2.first)
          create_list(:upvote, 2, book: book_set3.first)
        end

        let(:books) { [] }

        it 'will recommend most upvoted ones' do
          expected_book_ids = [book_set2.first.id, book_set3.first.id, book_set1.first.id]
          expect(subject.map(&:id)).to eq(expected_book_ids)
        end
      end
    end

    context 'with books for a base' do
      context 'without upvotes' do
        let(:books) { [book_set1.first, book_set2.first, book_set3.first] }

        it { is_expected.to be_empty }
      end

      context 'with many upvotes' do
        let(:books) { [book_set1.first, book_set2.first, book_set3.first] }

        before do
          create_list(:upvote, 4, book: book_set1.last)
          create_list(:upvote, 2, book: book_set2.last)
          create_list(:upvote, 3, book: book_set3.last)
        end

        context 'when most upvoted books are of the same authors' do
          it 'will recommend the most upvoted books of authors of the given book base preserving priority' do
            expected_book_ids = [book_set1.last.id, book_set2.last.id, book_set3.last.id]
            expect(subject.map(&:id)).to eq(expected_book_ids)
          end
        end

        context 'when most upvoted books are of many authors' do
          let(:recommendations) { 5 }
          let(:other_books) { create_list(:book, 2, genres: ['history','comedy']) }

          before do
            create_list(:upvote, 7, book: other_books.first)
            create_list(:upvote, 5, book: other_books.last)
          end

          it 'will recommend the most upvoted books of authors of the given book base and of most upvoted in general, preserving priority' do
            expected_book_ids = [book_set1.last.id, book_set2.last.id, book_set3.last.id, other_books.first.id, other_books.last.id]
            expect(subject.map(&:id)).to eq(expected_book_ids)
          end
        end
      end
    end
  end
end
