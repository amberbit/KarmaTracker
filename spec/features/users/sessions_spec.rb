require_relative '../../spec_helper'

feature 'Session management,
as a user
I can', register: true do

  let(:user) { create :confirmed_user }

  background do
    FakeWeb.allow_net_connect = true
    visit root_path
  end

  scenario 'log in', js: true do
    fill_in 'email', :with => user.email
    fill_in 'password', :with => 'secret123'
    click_button 'Sign in!'
    page.should have_content "Projects"
  end

  scenario 'log out', js: true do
    login user
    click_link "Log out"
    find_button "Sign in!"
  end

end
