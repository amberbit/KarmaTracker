require_relative '../../spec_helper'

feature 'Password reset management,
as a user
I can', js: true do

  let(:user) { create :confirmed_user }

  background do
    FakeWeb.allow_net_connect = true
  end

  scenario 'request email with reset password instructions' do
    visit '/'
    click_on 'forgotten password?'
    page.should have_content 'Reset password'
    fill_in 'Email', with: user.email
    click_on 'Reset Password'
    expect {
      page.should have_content 'Email with reset password instructions sent'
    }.to change{ user.reload.password_reset_token }.from(nil).to String
    user.password_reset_sent_at.to_date.should == Date.today
  end

  scenario 'reset password on edit reset password page' do
    user.password_reset_token = "token"
    user.password_reset_sent_at = Time.now
    user.save
    visit "#/edit_password_reset/#{user.password_reset_token}"
    page.should have_content 'Edit password'
    new_pass = 'abc123'
    fill_in 'password', with: new_pass
    fill_in 'password-confirmation', with: new_pass
    click_on 'Change password'
    page.should have_content 'Password successfully changed'
    User.find_by_email(user.email).try(:authenticate, new_pass).should == user
  end
end
