require 'rails_helper'

RSpec.describe User, type: :model do

  it { should have_many(:keywords) }
  

  it "should validate user record" do
    user = User.new
    expect(user.valid?).to be_falsey
  end

  it "should create user record with valid parameters" do
    user = create(:user)
    expect(user.valid?).to be_truthy
  end

  it "#find_keyword" do
    user = create(:user)
    new_keyword = build(:keyword)
    keyword = user.keywords.create(new_keyword.attributes)
    user_keyword = user.keywords.find_by(id: keyword.id)
    expect(user_keyword).to eq(keyword)
  end
end
