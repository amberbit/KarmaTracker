require 'spec_helper'

describe GitHubIdentity do

  it 'should not save identity when no credentials were provided' do
    GitHubIdentity.count.should == 0
    gi = GitHubIdentity.new
    gi.save
    GitHubIdentity.count.should == 0
  end

  it 'should not save identity when incorrect credentials were provided' do
    GitHubIdentity.count.should == 0
    gi = GitHubIdentity.new
    gi.username = 'wrong_username'
    gi.password = 'wrong_password'
    gi.save.should be_false
    gi.errors[:password].should be_present

    GitHubIdentity.count.should == 0
  end

  it 'should save identity if correct credentials were provided' do
    GitHubIdentity.count.should == 0
    gi = GitHubIdentity.new
    gi.user = FactoryGirl.create :user
    gi.username = 'correct_username@example.com'
    gi.password = 'correct_password'
    gi.save
    GitHubIdentity.count.should == 1
    GitHubIdentity.last.api_key.should == '5199831f4dd3b79e7c5b7e0ebe75d67aa66e79d4'
  end
end
