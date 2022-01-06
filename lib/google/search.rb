require 'net/http'

module Google
  class Search
    attr_reader :host, :cx_client, :app_key

    def initialize
      google     = Rails.application.credentials.config[:google]
      @host      = ENV['GHOST'] || google[:host]
      @cx_client = ENV['GCX']   || google[:ocx]
      @app_key   = ENV['GKEY']  || google[:okey]
    end

    def url(query)
      "#{host}?cx=#{cx_client}&key=#{app_key}&q=#{query}"
    end

    def search(query)
      return [false, { response: { error: 'Nothing to search' } }] if query.blank? || !query.is_a?(String)

      begin
        formated_url = url(CGI.escape(query))
        response     = Net::HTTP.get(URI(formated_url))
        build_results(JSON.parse(response))
      rescue StandardError => e
        Rails.logger.info 'Google::Search Error'
        Rails.logger.info e.message
        [false, { response: { error: e.message } }]
      end
    end

    def bulk_search(queries)
      bulk_results = {}
      threads = []
      queries.each do |query|
        threads << Thread.new do
          status, result      = search(query)
          bulk_results[query] = { status: status }.merge(result)
        end
      end
      threads.map(&:join)
      bulk_results
    end

    def build_results(response)
      return [false, { response: { error: 'Unable to parse' } }] unless response.is_a? Hash

      return [false, { response: { error: response['error']['message'] } }] if response['error']

      result = data_mapper(response)
      [true, result]
    end

    def item_links_and_html(response, links = [], html_snippet = [])
      response['items'].each do |item|
        links << item['link']
        html_snippet << item['htmlSnippet']
      end
      [links, html_snippet]
    end

    def data_mapper(response)
      format_hits  = response['searchInformation']['formattedTotalResults']
      search_time  = response['searchInformation']['formattedSearchTime']
      links, html  = item_links_and_html(response)
      {
        value: response['queries']['request'][0]['searchTerms'],
        hits: response['searchInformation']['totalResults'],
        html: html,
        links: links,
        search_time: search_time,
        stats: "About #{format_hits} results in (#{search_time} seconds)",
        next_page: response['queries']['nextPage'],
        response: response
      }
    end
  end
end
