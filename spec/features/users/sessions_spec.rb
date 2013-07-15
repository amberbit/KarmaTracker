require_relative '../../spec_helper'

feature 'Session management,
as a user
I can', js: true do

  let(:user) { create :confirmed_user }

  background do
    FakeWeb.allow_net_connect = true
    visit root_path
  end

  scenario 'log in' do
    fill_in 'email', :with => user.email
    fill_in 'password', :with => 'secret123'
    click_button 'Sign in!'
    page.should have_content "Projects"
  end

  scenario 'log out' do
    login user
    click_link "Log out"
    find_button "Sign in!"
  end

  scenario 'select remember me on login' do
    login user, true
    cookie = page.driver.cookies['token']
    cookie_date = Date.parse cookie.expires.to_s
    cookie_date.should == 30.days.from_now.to_date
  end
end
