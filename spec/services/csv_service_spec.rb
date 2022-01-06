require 'rails_helper'

describe CsvService do

  describe '.initialize' do
    it 'throw error when require argument missing' do
      expect { subject }.to raise_error ArgumentError
    end

    it 'should initialize with proper argument' do
      csv_service = CsvService.new(file: 'public/keyword_1.csv')
      expect(csv_service.file).to be_present
    end
  end

  describe '#read_file' do
    it 'should read and return contents in array' do
      csv_service = CsvService.new(file: './public/keyword_1.csv')
      expect(csv_service.read_file).to include('Rafael Nadal')
    end

    it 'should return empty array when error' do
      csv_service = CsvService.new(file: './public/no_file.csv')
      expect(csv_service.read_file).to be_empty
    end
  end
end
