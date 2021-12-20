FactoryBot.define do
  factory :user_keyword do
    user_id { sequence }
    keyword_id { sequence }
  end
end
