require 'spec_helper'

describe GitHubIntegration do

  it 'should not save integration when no credentials were provided' do
    GitHubIntegration.count.should == 0
    gi = GitHubIntegration.new
    gi.save
    GitHubIntegration.count.should == 0
  end

  it 'should not save integration when incorrect credentials were provided' do
    GitHubIntegration.count.should == 0
    gi = GitHubIntegration.new
    gi.username = 'wrong_username'
    gi.password = 'wrong_password'
    gi.save.should be_false
    gi.errors[:password].should be_present

    GitHubIntegration.count.should == 0
  end

  it 'should save integration if correct credentials were provided' do
    GitHubIntegration.count.should == 0
    gi = GitHubIntegration.new
    gi.user = FactoryGirl.create :user
    gi.username = 'correct_username@example.com'
    gi.password = 'correct_password'
    gi.save
    GitHubIntegration.count.should == 1
    GitHubIntegration.last.api_key.should == '5199831f4dd3b79e7c5b7e0ebe75d67aa66e79d4'
  end
end
