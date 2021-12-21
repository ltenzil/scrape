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
    it "should be able call url" do
      expect(subject).to receive(:url).with('ipad')
      subject.url('ipad')
    end

    it "should have query term in url" do
      url = subject.url('mac pro')
      expect(url).to include('q=mac pro')
    end
  end
end
