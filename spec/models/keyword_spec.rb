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

end
