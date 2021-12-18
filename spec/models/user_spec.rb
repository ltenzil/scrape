require 'rails_helper'

RSpec.describe User, type: :model do
  it "should validate user record" do
    user = User.new
    expect(user.valid?).to be_falsey
  end

  it "should create user record with valid parameters" do
    user = create(:user)
    expect(user.valid?).to be_truthy
  end
end
