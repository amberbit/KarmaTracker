require 'spec_helper'
require 'timecop'

describe 'User' do

  before :each do
    @user = FactoryGirl.create :user
  end

  it 'should validate user\'s attributes' do
    @user.valid?.should be_true

    invalid_user = User.create email: @user.email, password: nil
    invalid_user.valid?.should be_false
    invalid_user.errors.full_messages.should include "Email has already been taken"
    invalid_user.errors.full_messages.should include "Password digest can't be blank"
  end

  it 'should create user\'s api_key when new user is created' do
    @user.api_key should_not be_nil
    @user.api_key.should == ApiKey.first
  end

    it 'should create user\'s confirmation_token when new user is created' do
    @user.confirmation_token.should_not be_nil
  end


  it 'should validate format of email when creating user' do
    @user.email = 'foo'
    @user.should_not be_valid
    @user.errors[:email].should be_present
  end

  it 'generate token' do
    token = 'amberbit'
    SecureRandom.stub(:hex).and_return(token)
    @user.generate_token :password_reset_token
    @user.password_reset_token.should == token
  end

  it 'should update password reset sent at' do
    begin
      Timecop.freeze(Time.zone.now)
      @user.send(:update_password_reset_sent_at)
      @user.password_reset_sent_at.should == Time.zone.now
    ensure
      Timecop.return
    end
  end

end
