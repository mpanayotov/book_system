require 'rails_helper'

describe Feed do
  let(:user) { create(:user, :with_upvotes) }
  let(:user_upvotes) { user.upvotes }

  describe '#retrieve' do
    subject { described_class.new(user).retrieve }

    context 'without user history' do
      let(:user) { create(:user) }

      it { is_expected.to be_empty }
    end

    context 'with user history' do
      let(:third_upvoted_book) { user_upvotes[2].book }
      let(:fifth_upvoted_book) { user_upvotes[4].book }

      before do
        # follow third and fith author
        create :follow, author: third_upvoted_book.author, user: user
        create :follow, author: fifth_upvoted_book.author, user: user
      end

      it { is_expected.not_to be_empty }

      it 'returns list of all user upvotes' do
        expect(subject.map(&:id).sort).to eq(user_upvotes.map(&:id).sort)
      end

      it "book list is prioritized, followed authors\' books are showed first" do
        expect(subject.map(&:id)[0..1]).to eq([third_upvoted_book.id, fifth_upvoted_book.id])
      end
    end
  end

  describe '#refresh' do
    let(:feed) { described_class.new(user) }

    context 'with already retrieved book feed' do
      before { feed.retrieve }

      context 'without new upvoted books' do
        it 'shows empty list' do
          expect(feed.refresh).to eq([])
        end
      end

      context 'with new upvoted books' do
        it 'shows list new books for the user feed' do
          new_upvote = create :upvote, user: user
          expect(feed.refresh.map(&:id)).to eq([new_upvote.id])
        end
      end
    end

    context 'without retrieved book feed' do
      it 'shows whole book list' do
        expect(feed.refresh.map(&:id)).to eq(feed.retrieve.map(&:id))
      end
    end    
  end
end
