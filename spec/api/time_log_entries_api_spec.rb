require 'spec_helper'
require 'api/api_helper'

describe 'TimeLogEntry API' do

  before :each do
    @user = FactoryGirl.create :user
    @task = FactoryGirl.create :task
  end

  it 'should allow logging past time' do
    json = api_post "time_log_entries/", {token: @user.api_key.token,
           time_log_entry: {task_id: @task.id, started_at: '2000-01-01 01:00:00', stopped_at: '2000-01-01 02:00:00'} }

    response.status.should == 200
    json.has_key?('time_log_entry').should be_true
    json['time_log_entry']['seconds'].should == 3600

    TimeLogEntry.count.should == 1
  end

  it 'should allow ammending existing entries' do
    entry = FactoryGirl.create :time_log_entry
    old_stopped_at = entry.stopped_at
    new_stopped_at = Time.zone.now
    json = api_put "time_log_entries/#{entry.id}", {token: @user.api_key.token,
           time_log_entry: {stopped_at: new_stopped_at} }

    json.has_key?('time_log_entry').should be_true
    entry.reload
    entry.stopped_at.to_s.should_not == old_stopped_at.to_s
    entry.stopped_at.to_s.should == new_stopped_at.to_s
  end

  it 'should allow removing log entry and return it' do
    entry = FactoryGirl.create :time_log_entry
    -> {
      @json = api_delete "time_log_entries/#{entry.id}", {token: @user.api_key.token}
    }.should change(TimeLogEntry, :count).by(-1)

    response.status.should == 200
    @json.has_key?('time_log_entry').should be_true
    TimeLogEntry.count.should == 0
  end

  it 'should deny removing other user\'s log entry' do
    other_user = FactoryGirl.create :user
    other_entry = FactoryGirl.create :time_log_entry, user: other_user

    -> {
      @json = api_delete "time_log_entries/#{other_entry.id}", {token: @user.api_key.token}
    }.should change(TimeLogEntry, :count).by(0)

    response.status.should == 404
    @json.has_key?('time_log_entry').should be_false
    @json['message'].should == 'Resource not found'
    TimeLogEntry.count.should == 1
  end

end
