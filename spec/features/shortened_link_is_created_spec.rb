require 'rails_helper'

feature "shortened link is created" do
  context "with a valid url" do
    scenario "it returns a shortlink" do
      visit "/shortlinks/new"
      fill_in "Destination", with: 'http://www.testing.com'
      click_button 'Shorten!'
      expect(page).to have_content 'http://www.example.com/r/1'
    end
  end

  context "with an invalid url" do
    scenario "it returns an error message" do
      visit "/shortlinks/new"
      fill_in "Destination", with: "notaurl"
      click_button 'Shorten!'
      expect(page).to have_content 'valid URL?'
    end
  end
end
