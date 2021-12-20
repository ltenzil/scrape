FactoryBot.define do
  factory :keyword do
    value { "MyString" }
    hits { rand(0..1000) }
    stats { "MyString" }
  end
end
