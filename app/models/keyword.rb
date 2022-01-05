# Keyword model
class Keyword < ApplicationRecord
  validates :value, presence: true
  belongs_to :user
  before_save :squish_value

  LIMIT = 20

  def squish_value
    self.value = value.squish
  end

  def self.search(options = {})
    like_value(options)
      .where(user_query(options))
      .order(hits: :desc)
  end

  def self.like_value(options = {})
    return where(nil) if options[:value].blank?

    where('value ilike ?', "%#{options[:value]}%")
  end

  def self.user_query(options = {})
    options[:user_id].blank? ? nil : { user_id: options[:user_id] }
  end

  def search_google
    google = Google::Search.new
    _status, response = google.search(value)
    update(hits: response[:hits], stats: response[:stats],
           response: response[:response])
  end

  def self.bulk_search(queries, user_id)
    user = User.find_by_id(user_id)
    keywords, failures = [], []
    return [keywords, failures] if user.blank? || !queries.is_a?(Array)
    google = Google::Search.new
    queries.each do |query|
      status, response = google.search(query)
      if status
        keyword = user.keywords.create(value: query.squish.downcase)
        keyword.update(hits: response[:hits], stats: response[:stats],
          response: response[:response])
        keywords << keyword
      else
        failures << { query: query, error: response[:response][:error] }
      end
    end
    [keywords.uniq.compact, failures.uniq.compact]
  end

end
