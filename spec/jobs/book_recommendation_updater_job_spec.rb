require 'rails_helper'

describe BookRecommendationUpdaterJob, type: :job do
  let(:user) { create(:user) }

  it 'uses recommendation_update queque' do
    expect(described_class.queue).to eq :recommendation_update
  end

  describe '.enqueue!' do
    subject { described_class.enqueue!(user.id) }

    it 'enqueues a Resque job' do
      expect(Resque).to receive(:enqueue).with(described_class, user.id)
      subject
    end
  end

  describe '.perform' do
    let(:feed_books) { [{'id'=>3}, {'id'=>5}] }
    let(:feed) { double('Feed', retrieve: feed_books) }
    let(:recommendations) { [{'id'=>33}, {'id'=>49}] }
    let(:recommendation_builder) { double('BookRecommendationGenerator', call: recommendations) }

    before do
      allow(Feed).to receive(:new).with(user).and_return(feed)
      allow(BookRecommendationGenerator).to receive(:new).with(feed.retrieve).and_return(recommendation_builder)
    end

    subject { described_class.perform(user.id) }

    it 'logs job has started' do
      expect(Rails).to receive_message_chain(:logger, :info).with(no_args).with("Book recommendations for User:#{user.id} will be updated.")
      subject
    end

    it 'retrieves books feed' do
      expect(feed).to receive(:retrieve).and_return(feed_books)
      subject
    end

    it 'retrieves recommended books' do
      expect(recommendation_builder).to receive(:call).and_return(recommendations)
      subject
    end

    it 'updates recommendations' do
      expect(BookRecommendation).to receive_message_chain(:where, :first_or_create!, :update).with(user_id: user.id).with(book_ids: [33, 49])
      subject
    end

    context 'with raised error' do
      let(:error_message) { 'User sample error' }
      before { allow(User).to receive(:find).with(user.id).and_raise(error_message) }

      it 'error has been logged' do
        log_err_msg = "Updating book recommendations for User:#{user.id} failed with #{error_message}"
        expect(Rails).to receive_message_chain(:logger, :error).with(no_args).with(log_err_msg)
        subject
      end
    end
  end
end
