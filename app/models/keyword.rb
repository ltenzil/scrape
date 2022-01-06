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

end
