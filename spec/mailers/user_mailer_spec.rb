require 'spec_helper'
require 'api/api_helper'

describe UserMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers



  xit "should send an e-mail to user's address with user's confirmation token" do
    user = FactoryGirl.create :user
    email = UserMailer.confirmation_email(user, "localhost").deliver
    ActionMailer::Base.deliveries.last.to.should == [user.email]
    email.to[0].should == user.email
    email.subject.should == "KarmaTracker e-mail confirmation"
    email.body.should match(user.confirmation_token)
  end

  context 'password reset email,
    should' do

    let(:token) { 'amberbit' }
    let(:user) { stub_model User, email: 'email@amberbit.com', password_reset_token: token }
    let(:host) { 'localhost' }

    before(:each) do
      UserMailer.any_instance.stub(:get_root_url).and_return("amberbit.com")
      @email = UserMailer.password_reset(user, host)
    end

    it "be set to be delivered to the user passed in" do
      @email.should deliver_to user.email
    end

    it "contain reset password instructions" do
      @email.should have_body_text(/To reset your password, click the URL below/)
    end

    it "contain a link to edit reset password" do
      @email.should have_body_text(/amberbit\.com#\/edit_password_reset\/#{token}/)
    end

    it "have the correct subject" do
      @email.should have_subject(/KarmaTracker password reset/)
    end
  end


  context 'invalid api key,
    should' do

    let(:key) { 123 }
    let(:user) { stub_model User, email: 'email@amberbit.com' }
    let(:identity) { stub_model Identity, type: 'PivotalTrackerIdentity',
                     api_key: key, user: user }

    before(:each) do
      @email = UserMailer.invalid_api_key identity
    end

    it "be delivered to the user from identity" do
      @email.should deliver_to user.email
    end

    it "contain invalid api key info" do
      @email.should have_body_text(/Importing content for #{ identity.type } failed/)
      @email.should have_body_text(/Please check if API key: #{ identity.api_key } is valid./)
    end

    it "should have the correct subject" do
      @email.should have_subject(/KarmaTracker import failed. Invalid API key/)
    end
  end
end
