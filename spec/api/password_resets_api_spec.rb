require 'spec_helper'
require 'api/api_helper'


describe 'ResetPasswords API' do

  let(:user) do
    stub_model User, email: 'email@amberbit.com', password_reset_token: 'token',
      password_reset_sent_at: Time.zone.now
  end

  let(:user2) do
    create :user, password_reset_token: 'token',
      password_reset_sent_at: Time.zone.now
  end

  let(:host) { "amberbit.com" }
  let(:port) { 8080 }

  before :each do
    ActionDispatch::Request.any_instance.stub(:host).and_return(host)
    ActionDispatch::Request.any_instance.stub(:port).and_return(port)
    ActionMailer::Base.any_instance.stub(:deliver).and_return(true)
  end

  it 'should deliver the password reset email' do
    json = api_post 'password_reset', email: user2.email
    response.status.should == 200
    json['message'].should == 'Email with reset password instructions sent'
  end

  it 'should update users password' do
    new_pass = 'abc123'
    json = api_put 'password_reset', token: user2.password_reset_token,
      password: new_pass, confirmation: new_pass
    response.status.should == 200
    json['message'].should == 'Password successfully changed'
    User.find_by_email(user2.email).try(:authenticate, new_pass).should == user2
  end

  it 'should add error message to resposne when token generated > 24 ago' do
    user2.password_reset_sent_at = 25.hours.ago
    user2.save
    json = api_put 'password_reset', token: user2.password_reset_token
    response.status.should == 410
    json['error'].should == 'Reset password token expired. New token has been sent'
  end
end
