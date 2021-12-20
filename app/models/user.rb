class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :user_keywords, dependent: :destroy
  has_many :keywords, through: :user_keywords


  def find_keyword(keyword_id)
    return nil if keyword_id.blank?
    keywords.where(keywords: {id: keyword_id}).first
  end
  
end
