
require 'spec_helper'
describe PivotalTrackerIntegration do

  it 'should not save integration when no credentials were provided' do
    PivotalTrackerIntegration.count.should == 0
    pi = PivotalTrackerIntegration.new
    pi.save
    PivotalTrackerIntegration.count.should == 0
  end

  it 'should not save integration when incorrect credentials were provided' do
    PivotalTrackerIntegration.count.should == 0
    pi = PivotalTrackerIntegration.new
    pi.username = 'wrong_email'
    pi.password = 'wrong_password'
    pi.save
    PivotalTrackerIntegration.count.should == 0
  end

  it 'should save integration if correct credentials were provided' do
    PivotalTrackerIntegration.count.should == 0
    pi = PivotalTrackerIntegration.new
    pi.user = FactoryGirl.create :user
    pi.username = 'correct_username@example.com'
    pi.password = 'correct_password'
    pi.save
    PivotalTrackerIntegration.count.should == 1
    PivotalTrackerIntegration.last.api_key.should == '377ec0d3698e5f80c4e108fb26d7a105'

    pi = PivotalTrackerIntegration.new
    pi.user = FactoryGirl.create :user
    pi.username = 'correct_username'
    pi.password = 'correct_password'
    pi.save.should be_false
    pi.errors[:password].should be_present
  end
end
