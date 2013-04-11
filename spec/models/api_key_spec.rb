require 'spec_helper'

describe 'ApiKey' do

  it 'should create new ApiKey with unique token' do
    test_size = 10
    (1..test_size).each do
      FactoryGirl.create(:user)
    end

    ApiKey.count.should == test_size
    ApiKey.all(&:token).uniq.count.should == test_size
  end

end
