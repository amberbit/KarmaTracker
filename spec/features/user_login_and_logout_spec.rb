require 'spec_helper'

feature 'User login and logout', register: true do

  background do
    FakeWeb.allow_net_connect = true
  end

  scenario 'signs in', js: true do
    user = FactoryGirl.create :user
    user.update_attribute :confirmation_token, nil
 
    visit root_path
    fill_in 'email', :with => user.email
    fill_in 'password', :with => 'secret123'
    click_button 'Sign in!'
    page.should have_content "Projects"
  end

  scenario 'logs out', js: true do
    user = FactoryGirl.create :user
    user.update_attribute :confirmation_token, nil
 
    visit root_path
    fill_in 'email', :with => user.email
    fill_in 'password', :with => 'secret123'
    click_button 'Sign in!'
    page.should have_content "Log out"
    click_link "Log out"
    find_button "Sign in!"

  end


end
