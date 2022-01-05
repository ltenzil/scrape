require 'rails_helper'

RSpec.describe Keyword, type: :model do

  it { should belong_to(:user) }

  let(:user) { create(:user) }

  let(:dummy_json) {
    {
      hits: 1000000,
      html: ['<div>Found </div>'],
      links: ["<a href='google.com'>Results</>"],
      search_time: '0.45',
      stats: 'About 1,000,000 results in (0.45 seconds)',
      next_page: [],
      response: {
        next_page: [],
        items: []
      }
    }
  }

  let(:quota_error) {
    { response: { error: 'Quota utilised error' } }
  }

  describe '#squish_value' do
    it 'should remove additional space in keyword' do
      keyword = create(:keyword, value: ' hello   world   ', user_id: user.id)
      expect(keyword.value).to eq('hello world')
    end
  end

  describe '#search_google' do
    it 'should fetch results and update' do
      keyword = create(:keyword, value: 'ipad', user_id: user.id)
      allow_any_instance_of(Google::Search).to receive(:search).with(keyword.value).and_return([true, dummy_json])      
      keyword.search_google
      expect(keyword.response).to eq(dummy_json[:response].with_indifferent_access)
    end

    it 'should fetch results and update even when error' do
      keyword = create(:keyword, value: 'ipad', user_id: user.id)
      allow_any_instance_of(Google::Search).to receive(:search).with(keyword.value).and_return([false, quota_error])
      keyword.search_google
      expect(keyword.response).to eq(quota_error[:response].with_indifferent_access)
    end
  end

  describe '.bulk_search' do
    let(:user) { create(:user) }
    before :each do      
      allow(Google::Search).to receive(:new).and_call_original
    end
    
    it 'should fetch and save results' do
      queries = ['Ruby']         
      allow_any_instance_of(Google::Search).to receive(:search).with('Ruby').and_return([true, dummy_json])      
      keywords, failures = Keyword.bulk_search(queries, user.id)
      expect(Keyword.last.value).to eq('ruby')
      expect(Keyword.last.hits).to eq(1000000)
      expect(keywords).to include(Keyword.last)
      expect(failures).to be_empty
    end

    it 'should return Quota utilised error' do
      queries = ['Elixir']
      allow_any_instance_of(Google::Search).to receive(:search).with('Elixir').and_return([false, quota_error])      
      keywords, failures = Keyword.bulk_search(queries, user.id)
      expect(keywords).to be_empty
      expect(failures).to eq([{error: "Quota utilised error", query: "Elixir"}])
    end
  end

end
