require "rails_helper"

feature "can view all link pairs" do
  context "there are no link pairs" do
    scenario "it displays a graceful message" do
      visit "/"
      click_on "Links"
      expect(page).to have_content("no shortlinks")
    end
  end

  context "there are link pairs" do
    scenario "it displays the single pair" do
      Shortlink.create(destination: "http://www.example.com")
      visit "/"
      click_on "Links"
      expect(page).to have_content("r/1")
    end

    scenario "it displays all of the link pairs" do
      10.times { Shortlink.create(destination: "http://www.example.com") }
      visit "/"
      click_on "Links"
      expect(page).to have_content("r/5")
      expect(page).to have_content("r/a")
    end
  end
end
