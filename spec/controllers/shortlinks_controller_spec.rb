require 'rails_helper'

describe ShortlinksController do
  describe "GET new" do
    it "sets @shortlink" do
      get :new
      expect(assigns(:shortlink)).to be_present
    end
  end

  describe "POST create" do
    context "with valid destination URL" do
      before do
        post :create, params: { shortlink: { destination: "http://www.example.com" } }
      end

      it "creates a shortlink" do
        expect(Shortlink.count).to eq(1)
      end

      it "sets a success flash message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to the new path" do
        expect(response).to redirect_to(new_shortlink_path)
      end
    end

    context "with invalid destination URL" do
      before do
        post :create, params: { shortlink: { destination: "example.com" } }
      end

      it "sets a flash error message" do
        expect(flash[:error]).to be_present
      end

      it "does not create a shortlink" do
        expect(Shortlink.count).to eq(0)
      end

      it "redirects to the new path" do
        expect(response).to redirect_to(new_shortlink_path)
      end
    end
  end
end
