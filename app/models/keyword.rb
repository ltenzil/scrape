class Keyword < ApplicationRecord
  validates :value, presence: true, uniqueness: true
  has_many :user_keywords, dependent: :destroy
  has_many :users, through: :user_keywords
end
