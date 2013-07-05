def login(user = create(:user))
  visit root_path
  fill_in 'email', :with => user.email
  fill_in 'password', :with => 'secret123'
  click_button 'Sign in!'
  page.should have_content 'Log out'
end

def wait_until(timeout = Capybara.default_wait_time)
  Timeout.timeout(timeout) do
    sleep(0.1) until value = yield
    value
  end
end
