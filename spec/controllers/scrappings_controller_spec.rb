require 'rails_helper'

RSpec.describe ScrappingsController, type: :controller do

  describe "GET #response_code" do
    it "returns http success" do
      get :response_code
      expect(response).to have_http_status(:success)
    end
  end

end
