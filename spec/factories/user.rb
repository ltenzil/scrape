FactoryBot.define do
  factory :user do
    sequence(:email) { |id| "test_#{id.to_s.rjust(3, "0")}@sample.com" }
    password { "!qaz@2wsx" }
  end
end
