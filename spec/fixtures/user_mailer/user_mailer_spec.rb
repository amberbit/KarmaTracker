require 'spec_helper'
require 'api/api_helper'

describe 'User Mailer' do

  before :each do
    @user = FactoryGirl.create :user
  end

  it "should send an e-mail to user's address with user's confirmation token" do
    email = UserMailer.confirmation_email(@user, request.host).deliver
    ActionMailer::Base.deliveries.last.to.should == [@user.email]
    email.to[0].should == @user.email
    email.subject.should == "KarmaTracker e-mail confirmation"
    email.body.should match(@user.confirmation_token)

  end
end
