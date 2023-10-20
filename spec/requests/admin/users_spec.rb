require 'rails_helper'

RSpec.describe "Admin::Users" do
  describe "GET /new" do
    it "returns http success" do
      get "/admin/users/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/users/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/users/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /index" do
    it "returns http success" do
      get "/admin/users/index"
      expect(response).to have_http_status(:success)
    end
  end
end
