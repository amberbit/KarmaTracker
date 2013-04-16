require 'spec_helper'

describe PivotalTrackerIdentity do

  it 'should not save identity when no credentials were provided' do
    PivotalTrackerIdentity.count.should == 0
    pi = PivotalTrackerIdentity.new
    pi.save
    PivotalTrackerIdentity.count.should == 0
  end

  it 'should not save identity when incorrect credentials were provided' do
    PivotalTrackerIdentity.count.should == 0
    pi = PivotalTrackerIdentity.new
    pi.email = 'wrong_email'
    pi.password = 'wrong_password'
    pi.save
    PivotalTrackerIdentity.count.should == 0
  end

  it 'should save identity if correct credentials were provided' do
    PivotalTrackerIdentity.count.should == 0
    pi = PivotalTrackerIdentity.new
    pi.user = FactoryGirl.create :user
    pi.email = 'correct_email'
    pi.password = 'correct_password'
    pi.save
    PivotalTrackerIdentity.count.should == 1
    PivotalTrackerIdentity.last.api_key.should == '377ec0d3698e5f80c4e108fb26d7a105'
  end
end
