# service file to perform search and create keywords
class KeywordService
  attr_reader :user, :google_client

  def initialize(user:)
    @user          = user
    @google_client = Google::Search.new
  end

  def search_google(query)
    @google_client.search(query)
  end

  def bulk_search(queries)
    @google_client.bulk_search(queries)
  end

  def search_and_save(query)
    status, response = search_google(query)
    return add_errors(query, response) unless status

    create_keyword(response)
  end

  def search_and_update(keyword)
    _status, response = search_google(keyword.value)
    keyword.update(data_mapper(response))
  end

  def bulk_search_and_save(queries)
    response = bulk_search(queries)
    create_bulk(response)
  end

  def create_keyword(options = {})
    @user.keywords.create(data_mapper(options))
  end

  def add_errors(query, response)
    keyword = @user.keywords.new(value: query)
    keyword.errors.add(:value, response[:response][:error])
    keyword
  end

  def create_bulk(results, keywords = [], failures = [])
    results.each do |query, result|
      status, response = save_result(result, query)
      status ? (keywords << response) : (failures << response)
    end
    [keywords, failures]
  end

  def save_result(result, query)
    if result[:status]
      [true, create_keyword(data_mapper(result))]
    else
      [false, { query: query, error: result[:response][:error] }]
    end
  end

  def data_mapper(response)
    {
      value: response[:value],
      hits: response[:hits],
      stats: response[:stats],
      response: response[:response]
    }
  end
end
