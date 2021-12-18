require 'rails_helper'

RSpec.describe PagesController, type: :controller do 
  render_views

  describe "Get /" do
    
    context "from login user" do
      let(:current_user) { create(:user) }
      before :each do
        sign_in current_user
      end
      it "should return index page" do
        get :index
        expect(response).to have_http_status(:success)
      end      
    end

    context "guest user" do
      it "should get login form" do
        get :index
        expect(response).to redirect_to("/users/sign_in")
      end      
    end
  end
end
