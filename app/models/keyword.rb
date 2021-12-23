class Keyword < ApplicationRecord
  validates :value, presence: true, uniqueness: true
  has_many :user_keywords, dependent: :destroy
  has_many :users, through: :user_keywords

  before_save :squish_value

  LIMIT = 20

  def squish_value
    self.value = value.squish
  end

  def self.search(options={})
    joins(user_keywords_sym(options))
    .where(user_query(options))
    .where("value ilike ?", "%#{options[:value]}%")
    .order(hits: :desc)
  end

  def self.user_keywords_sym(options={})
    options[:user_id].blank? ? nil : (:user_keywords)
  end

  def self.user_query(options={})
    return nil if options[:user_id].blank?
    { user_keywords: { user_id: options[:user_id] } }
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
        keyword = user.keywords.find_or_create_by(value: query.squish.downcase)
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
