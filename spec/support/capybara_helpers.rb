def login(user = create(:user), remember_me = false)
  visit root_path
  wait_until(10) { page.has_css? '#email' }
  fill_in 'email', :with => user.email
  fill_in 'password', :with => 'secret123'
  check('Remember me') if remember_me
  click_button 'Sign in!'
  page.should have_content 'Recents'
end

def wait_until(timeout = Capybara.default_wait_time)
  Timeout.timeout(timeout) do
    sleep(0.1) until value = yield
    value
  end
end

#poltergeist/phantomjs only
def take_screenshot filename = "screenshot"
  file = "#{Dir.pwd}/tmp/screenshots/#{filename}_#{Time.now.to_formatted_s(:number)}.png"
  page.driver.render(file, :full => true)
  puts "Saved screenshot: #{file}"
end
