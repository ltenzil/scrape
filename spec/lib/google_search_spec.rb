require 'rails_helper'

describe Google::Search do

  describe ".initialize" do
    it "should have cx" do
      expect(subject.cx_client).to be_present
    end

    it "should have app key" do
      expect(subject.app_key).to be_present
    end

    it "should have host" do
      expect(subject.host).to be_present
    end
  end

  describe "#url" do
    it "should be able to call url" do
      expect(subject).to receive(:url).with('ipad')
      subject.url('ipad')
    end

    it "should have query term in url" do
      url = subject.url('mac pro')
      expect(url).to include('q=mac pro')
    end
  end

  describe "#search" do

    let(:invalid_url) {
      "https://customsearch.googleapis.com/customsearch/v1??cx=cx_value&key=value&q=term"
    }

    let(:ipad_result) do
      {
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
      {'ipad' => ipad_result, 'ruby' => ruby_result}
    end

    let(:quota_error) {
      { response: { error: 'Quota utilised error' } }
    }

    it "should be able to call search" do
      expect(subject).to receive(:search).with('ipad')
      subject.search('ipad')
    end

    it "should be able to call bulk_search" do
      expect(subject).to receive(:bulk_search).with(['ipad', 'ruby'])
      subject.bulk_search(['ipad', 'ruby'])
    end

    it "should receive results" do
      allow_any_instance_of(subject.class).to receive(:search).with('ipad').and_return([true, ipad_result])
      expect(subject.search('ipad')).to eq([true, ipad_result])
    end

    it "should receive bulk results" do
      allow_any_instance_of(subject.class).to receive(:bulk_search).with(['ipad', 'ruby']).and_return(bulk_response)
      expect(subject.bulk_search(['ipad', 'ruby'])).to eq(bulk_response)
    end

    it "should receive error when quota utilized" do
      allow_any_instance_of(subject.class).to receive(:search).with('ipad').and_return([false, quota_error])
      expect(subject.search('ipad')).to eq([false, quota_error])
    end

  end
end
