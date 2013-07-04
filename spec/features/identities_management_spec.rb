require 'spec_helper'

feature 'Identities management', register: true do

  background do
    FakeWeb.allow_net_connect = true
    user = FactoryGirl.create :user
    user.update_attribute :confirmation_token, nil
    login user
    click_link 'Profile'
    click_link 'Integrations'
    page.should have_content 'Integrations'
    page.should have_content 'Pivotal Tracker'
  end

  scenario 'adds and removes new Pivotal Tracker identity with credentials', js: true do
    click_link 'add_new_pt'
    within 'div#ptform' do
      fill_in 'name', :with => 'Example'
      fill_in 'email', :with => 'correct_email'
      fill_in 'password', :with => 'correct_password'
      click_button "Add new identity"
    end
    page.should have_content 'Example'
    click_link 'Remove'
    page.should_not have_content 'Example'
  end

  scenario 'adds and removes new Pivotal Tracker identity with token', js: true do
    click_link 'add_new_pt'
    within 'div#ptform' do
      fill_in 'name', :with => 'Example'
      fill_in 'token', :with => 'correct_token'
      click_button "Add new identity"
    end
    page.should have_content 'Example'
    click_link 'Remove'
    page.should_not have_content 'Example'
  end


  scenario 'adds and removes new Git Hub identity with credentials', js: true do
    click_link 'add_new_gh'
    within 'div#ghform' do
      fill_in 'name', :with => 'Example'
      fill_in 'username', :with => 'correct_username'
      fill_in 'password', :with => 'correct_password'
      click_button "Add new identity"
    end
    page.should have_content 'Example'
    click_link 'Remove'
    page.should_not have_content 'Example'
  end

  scenario 'adds and removes new Git Hub identity with token', js: true do
    click_link 'add_new_gh'
    within 'div#ghform' do
      fill_in 'name', :with => 'Example'
      fill_in 'token', :with => 'correct_token'
      click_button "Add new identity"
    end
    page.should have_content 'Example'
    click_link 'Remove'
    page.should_not have_content 'Example'
  end

  scenario 'field Name should not be empty when adding new Pivotal Tracker identity', js: true do
    click_link 'add_new_pt'
    within 'div#ptform' do
      fill_in 'email', :with => 'correct_email'
      fill_in 'password', :with => 'correct_password'
      click_button "Add new identity"
    end
    page.should have_content "can't be blank"
  end

  scenario 'field Name should not be empty when adding new Git Hub identity', js: true do
    click_link 'add_new_gh'
    within 'div#ghform' do
      fill_in 'username', :with => 'correct_username'
      fill_in 'password', :with => 'correct_password'
      click_button "Add new identity"
    end
    page.should have_content "can't be blank"
  end

    scenario 'credential fields should not be empty when adding new Pivotal Tracker identity', js: true do
    click_link 'add_new_pt'
    within 'div#ptform' do
      fill_in 'name', :with => 'Example'
      click_button "Add new identity"
    end
    page.should have_content "you need to provide login credentials"
  end

  scenario 'credential fields should not be empty when new Git Hub identity', js: true do
    click_link 'add_new_gh'
    within 'div#ghform' do
      fill_in 'name', :with => 'Example'
      click_button "Add new identity"
    end
    page.should have_content "can't be blank"
  end
end
