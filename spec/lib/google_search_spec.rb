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

    it "should be able to call search" do
      expect(subject).to receive(:search).with('ipad')
      subject.search('ipad')
    end

    it "should receive results" do
      allow_any_instance_of(subject.class).to receive(:search).with('ipad').and_return([true, dummy_json])
      expect(subject.search('ipad')).to eq([true, dummy_json])
    end

    it "should receive error when quota utilized" do
      allow_any_instance_of(subject.class).to receive(:search).with('ipad').and_return([false, quota_error])
      expect(subject.search('ipad')).to eq([false, quota_error])
    end

  end
end
