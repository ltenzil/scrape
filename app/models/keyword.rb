class Keyword < ApplicationRecord
  validates :value, presence: true, uniqueness: true
  has_many :user_keywords, dependent: :destroy
  has_many :users, through: :user_keywords

  LIMIT = 20

  def search_google
    google = Google::Search.new
    status, response = google.search(value)
    update(hits: response[:hits],
           stats: response[:stats]) if status
  end

  def self.bulk_search(queries, user_id)
    user = User.find_by_id(user_id)
    return [] if user.blank? || !queries.is_a?(Array)
    google = Google::Search.new
    keywords, failures = [], []
    queries.each do |query|
      status, response = google.search(query)
      if status
        keyword = find_or_create_by(value: query.downcase)
        if keyword.users.blank?
          UserKeyword.find_or_create_by(user_id: user.id, keyword_id: keyword.id)
        end
        keyword.update(hits: response[:hits], stats: response[:stats])
        keywords << keyword
      else
        failures << { query: query, error: response[:error] }
      end
    end
    [keywords.uniq.compact, failures.uniq.compact]
  end

end
