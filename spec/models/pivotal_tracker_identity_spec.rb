require_relative '../spec_helper'
require 'fakeweb'

describe PivotalTrackerIdentity do
  before :all do
    FakeWeb.allow_net_connect = false

    FakeWeb.register_uri(:get, 'https://wrong_email:wrong_password@www.pivotaltracker.com/services/v4/me',
      :body => 'Access Denied', :status => ['401', 'Unauthorized'])

    FakeWeb.register_uri(:get, 'https://correct_email:correct_password@www.pivotaltracker.com/services/v4/me',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'authorization_success.xml')),
      :status => ['200', 'OK'])
  end

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

  it 'should save identity if correct credentials  were provided' do
    PivotalTrackerIdentity.count.should == 0
    pi = PivotalTrackerIdentity.new
    pi.email = 'correct_email'
    pi.password = 'correct_password'
    pi.save
    PivotalTrackerIdentity.count.should == 1
    PivotalTrackerIdentity.last.api_key.should == '377ec0d3698e5f80c4e108fb26d7a105'
  end
end
