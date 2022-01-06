# CSV service class to read file contents
class CsvService

  attr_reader :file

  def initialize(file:)
    @file = file
  end

  def read_file
    begin
      contents = File.read @file
      queries  = contents.split(/[\r\n,]+/).map(&:squish)
    rescue StandardError => e
      Rails.logger.info "Csv Read error: #{e.message}"
      queries = []
    end
    queries
  end
end
