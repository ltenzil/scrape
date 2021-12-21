class Keyword < ApplicationRecord
  validates :value, presence: true, uniqueness: true
  has_many :user_keywords, dependent: :destroy
  has_many :users, through: :user_keywords

  def search_google
    google = Google::Search.new
    status, response = google.search(value)
    update(hits: response[:hits],
           stats: response[:stats]) if status
  end

  def self.bulk_search(queries, user_id)
    user = User.find_by_id(user_id)
    return "User not found" unless user
    return "Expected list of words" unless queries.is_a? Array
    google = Google::Search.new
    queries -= [0, '', nil]
    queries.each do |query|
      keyword = find_or_create_by(value: query.downcase)
      if keyword.users.blank?
        UserKeyword.find_or_create_by(user_id: user.id, keyword_id: keyword.id)
      end
      status, response = google.search(keyword.value)
      if status
        keyword.update(hits: response[:hits], stats: response[:stats])
      else
        keyword.update(stats: response[:error])
      end
    end
  end

end
