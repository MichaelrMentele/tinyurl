require 'rails_helper'

feature "a user enters their own path" do
  context "for a vacant path" do
    scenario "it returns a short link with that path" do
      visit '/'
      click_on "Home"
      fill_in "Destination", with: "http://test.com"
      fill_in "Slug", with: "wize"
      click_on "Shorten!"

      expect(page).to have_content "http://www.example.com/r/wize"
    end
  end

  context "for an occupied path" do
    scenario "it returns an error message that the path is already taken" do
      Shortlink.create!(id: Base62.to_base_10_from_62('wize'), slug: 'wize', destination: "http://ex.com")
      visit '/'
      click_on "Home"
      fill_in "Destination", with: "http://test.com"
      fill_in "Slug", with: "wize"
      click_on "Shorten!"

      expect(page).to have_content "that link is taken."
    end
  end
end
