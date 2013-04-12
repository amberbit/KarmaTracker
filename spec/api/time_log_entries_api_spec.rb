require 'spec_helper'
require 'api/api_helper'

describe 'TimeLogEntry API' do

  before :each do
    @user = FactoryGirl.create :user
    @task = FactoryGirl.create :task
  end

  it 'should allow logging past time' do
    json = api_post "time_log_entries/", {token: @user.api_key.token,
           time_log_entry: {task_id: @task.id, started_at: 2.hours.ago, stopped_at: 1.hours.ago} }

    response.status.should == 200
    json.has_key?('time_log_entry').should be_true

    TimeLogEntry.count.should == 1
  end

end
