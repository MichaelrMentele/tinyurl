require 'rails_helper'

feature "views top 10 most linked to domains" do
  context "no links exist" do
    scenario "it returns a notice" do
      visit '/'
      click_on "Top Domains"
      expect(page).to have_content "There are no links"
    end
  end

  context "at least 10 active links exist" do
    scenario "it displays the top 10 links" do
      # TODO: needs to count that there are 10 rows
      visit '/'
      click_on "Top Domains"
      # 20.times { Shortlink.create(destination: "http://" + ["a".."z"].sample + ".com")}
      # 2.times { Shortlink.create(destination: "http://ex.com")}
      # 10.times { Shortlink.create(destination: "http://google.com") }
      # expect(page).to have_content "http://google.com"
    end

    scenario "it displays the top 10 links in order"
  end
end
