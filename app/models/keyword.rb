class Keyword < ApplicationRecord
  validates :value, presence: true, uniqueness: true
  has_many :user_keywords, dependent: :destroy
  has_many :users, through: :user_keywords

  before_save :downcase_value

  LIMIT = 20

  def downcase_value
    self.value = value.downcase
  end

  def self.search(options={})
    where("value ilike ?", "%#{options[:value]}%")
    .order(hits: :desc)
  end

  def search_google
    google = Google::Search.new
    status, response = google.search(value)
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
        keyword = user.keywords.find_or_create_by(value: query.downcase.squish)
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
