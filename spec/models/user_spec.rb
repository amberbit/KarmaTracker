require 'spec_helper'

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

end
