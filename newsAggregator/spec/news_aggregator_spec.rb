require "spec_helper"

feature "User submits a new article", %(
  - the /articles/new path leads to a page with a form expecting url, title, and description
  - the form has the following types of validation which, when failed return user to the form, still filled out:
  --- the form won't submit with empty fields
  --- the form won't submit with description less than 20 char
  --- the form won't submit with an invalid link
  - Once succesfuly validated the page redirects the user to the articles page where they can view their newly submitted article.


  ) do

  context "User visits the new article form" do

    scenario "user clicks the 'New Article' link from the main page and submits a valid form" do
      visit "/"
      click_link "Submit New Article"
      expect(page).to have_content("Submit your distracting article here:")
      fill_in "Title:", with: 'Test Title'
      fill_in "URL:", with: 'http://afakeurl.com'
      fill_in "Description:", with: 'A description of at least twenty characters'
      click_button "Submit"
      expect(page).to have_content("A description of at least twenty characters")
      expect(page).to have_content("Test Title")
    end

    scenario "User submits a form with an empty fields" do
      visit "/articles/new"
      click_button "Submit"
      expect(page).to have_content("Submit your distracting article here:")
      expect(page).to have_content("Please enter a title.")
      expect(page).to have_content("Please enter a valid URL.")
      expect(page).to have_content("Please enter a description of at least 20 characters.")
    end

    scenario "User submits a description with fewer than 20 characters" do
      visit "/articles/new"
      fill_in "Description:", with: 'Short description'
      click_button "Submit"
      expect(page).to have_content("Submit your distracting article here:")
      expect(page).to have_content("Please enter a description of at least 20 characters.")
    end

    scenario "User submits a duplicate article" do
      visit "/articles/new"
      fill_in "Title:", with: 'Test Title'
      fill_in "URL:", with: 'http://afakeurl.com'
      fill_in "Description:", with: 'A description of at least twenty characters'
      click_button "Submit"
      expect(page).to have_content("Revision required:")
      expect(page).to have_content("This link has already been submitted")
      clean_csv
    end
  end
end