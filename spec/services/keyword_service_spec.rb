require 'rails_helper'

describe KeywordService do

  describe '.initialize' do
    let(:user) { create(:user) }

    it 'throw error when require argument missing' do
      expect { subject }.to raise_error ArgumentError
    end

    it 'should have user' do
      keyword_service = KeywordService.new(user: user)
      expect(keyword_service.user).to eq(user)
    end

    it 'should have google client' do
      keyword_service = KeywordService.new(user: user)
      expect(keyword_service.google_client.class.to_s).to eq(Google::Search.to_s)
    end

  end

  describe '#search_google' do

    let(:user) { create(:user) }
    let(:keyword_service) { KeywordService.new(user: user) }

    let(:ipad_result) do
      {
        status: true,
        value: 'ipad',
        hits: 1_000_000,
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
    end

    let(:ruby_result) do
      {
        status: true,
        value: 'ruby',
        hits: 1_050_000,
        html: ['<div>Found </div>'],
        links: ["<a href='google.com'>Results</>"],
        search_time: '0.5',
        stats: 'About 1,050,000 results in (0.5 seconds)',
        next_page: [],
        response: {
          next_page: [],
          items: []
        }
      }
    end

    let(:bulk_response) do
      { 'ipad' => ipad_result, 'ruby' => ruby_result }
    end

    let(:quota_error) do
      { status: false, response: { error: 'Quota utilised error' } }
    end

    let(:queries) { ['ipad', 'ruby'] }

    context '#search_google' do
      before :each do
        allow(Google::Search).to receive(:new).and_call_original
      end

      it 'should call google search' do
        allow_any_instance_of(Google::Search).to receive(:search).with('ipad').and_return([true, ipad_result])
        keyword_service.search_google('ipad')
      end

      it 'should fetch results and update even when error' do
        allow_any_instance_of(Google::Search).to receive(:search).with('ipad').and_return([false, quota_error])
        keyword = keyword_service.search_and_save('ipad')
        expect(keyword.errors).not_to be_empty
      end
    end

    context '#bulk_search' do
      it 'should call google bulk search' do
        allow_any_instance_of(Google::Search).to receive(:bulk_search).with(queries).and_return(bulk_response)
        keyword_service.bulk_search(queries)
      end

      it 'should fetch and save results' do
        allow_any_instance_of(Google::Search).to receive(:bulk_search).with(queries).and_return(bulk_response)
        keywords, _failures = keyword_service.bulk_search_and_save(queries)
        expect(keywords.last.value).to eq('ruby')
      end
    end
  end

end
