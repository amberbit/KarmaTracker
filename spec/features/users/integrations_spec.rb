require 'spec_helper'

feature 'Integrations management', js: true do

  background do
    FakeWeb.allow_net_connect = true
    user = FactoryGirl.create :user
    user.update_attribute :confirmation_token, nil
    Capybara.reset_session!
    login user
    within '#firstTip' do
      click_on 'Ok'
    end
    page.should have_content 'Integrations'
    page.should have_content 'Pivotal Tracker'
  end

  scenario 'adds and removes new Pivotal Tracker integration with credentials' do
    click_link 'add_new_pivotal_tracker'
    within 'div#pivotal_tracker_form' do
      fill_in 'username', :with => 'correct_username@example.com'
      fill_in 'password', :with => 'correct_password'
      click_button "Add new integration"
    end
    page.should have_content 'API Key'
    click_link 'Remove'
    page.should_not have_content 'API Key'
  end

  scenario 'adds and removes new Pivotal Tracker integration with token' do
    click_link 'add_new_pivotal_tracker'
    find('a', text: "API Key").click
    within 'div#pivotal_tracker_form' do
      fill_in 'token', :with => 'correct_token'
      click_button "Add new integration"
    end
    page.should have_content 'API Key'
    click_link 'Remove'
    page.should_not have_content 'API Key'
  end


  scenario 'adds and removes new Git Hub integration with credentials' do
    click_link 'add_new_git_hub'
    within 'div#git_hub_form' do
      fill_in 'username', :with => 'correct_username@example.com'
      fill_in 'password', :with => 'correct_password'
      click_button "Add new integration"
    end
    page.should have_content 'API Key'
    click_link 'Remove'
    page.should_not have_content 'API Key'
  end

  scenario 'adds and removes new Git Hub integration with token' do
    click_link 'add_new_git_hub'
    find('a', text: "API Key").click
    within 'div#git_hub_form' do
      fill_in 'token', :with => 'correct_token'
      click_button "Add new integration"
    end
    page.should have_content 'API Key'
    click_link 'Remove'
    page.should_not have_content 'API Key'
  end

  scenario 'credential fields should not be empty when adding new Pivotal Tracker integration' do
    click_link 'add_new_pivotal_tracker'
    within 'div#pivotal_tracker_form' do
      click_button "Add new integration"
    end
    page.should have_content "can't be blank"
  end

  scenario 'credential fields should not be empty when new Git Hub integration' do
    click_link 'add_new_git_hub'
    within 'div#git_hub_form' do
      click_button "Add new integration"
    end
    page.should have_content "can't be blank"
  end
end
