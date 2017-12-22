require 'rails_helper'

RSpec.describe ScrappingsController, type: :controller do

  describe "GET #search2" do
    it "returns http success" do
      get :search2
      expect(response).to have_http_status(:success)
    end
  end

end
