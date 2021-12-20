require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ApplicationHelper. For example:
#
# describe ApplicationHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end

RSpec.describe ApplicationHelper, type: :helper do
  
  describe "User name" do
    it "should return nil as name without login" do
      expect(helper.fetch_name).to be_nil
    end

    it "should return user name with login" do
      current_user = create(:user, email: "test@gmail.com")
      sign_in current_user
      expect(helper.fetch_name).to eq("test")
    end
  end

end
