require_relative '../../spec_helper'

feature 'Session management,
as a user
I can', js: true do

  let(:user) { create :confirmed_user }

  background do
    FakeWeb.allow_net_connect = true
    visit root_path
  end
  
  scenario 'see "Log in" header on login screen' do
    page.should have_selector('h4', text: "Log in")
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

  scenario "after logout I don't get redirected to projects page" do
    login user
    click_on 'Log out'
    page.should_not have_content 'Projects'
    page.should have_field 'email'
  end
end
