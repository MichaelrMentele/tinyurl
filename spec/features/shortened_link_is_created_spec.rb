require 'rails_helper'

feature "shortened link is created" do
  context "with a valid url" do
    scenario "it returns a shortlink" do
      visit "/"
      click_on "Home"
      fill_in "Destination", with: 'http://www.testing.com'
      click_button 'Shorten!'
      # Note: this is the root domain for test env.
      within "#flash" do
        expect(page.text).not_to end_with 'http://www.example.com/r/'
      end
    end
  end

  context "with an invalid url" do
    scenario "it returns an error message" do
      visit "/"
      click_on "Home"
      fill_in "Destination", with: "notaurl"
      click_button 'Shorten!'
      expect(page).to have_content 'valid URL?'
    end
  end
end
