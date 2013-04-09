require 'spec_helper'

describe 'ApiKey' do

  it 'should create new ApiKey with unique access_token' do
    test_size = 100
    (1..test_size).each do
      FactoryGirl.create(:user)
    end

    ApiKey.count.should == test_size
    ApiKey.all(&:access_token).uniq.count.should == test_size
  end

end
