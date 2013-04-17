require 'spec_helper'
require 'api/api_helper'

describe 'TimeLogEntry API' do

  before :each do
    project = FactoryGirl.create :project
    identity = FactoryGirl.create :identity
    project.identities << identity
    @user = identity.user
    @task = FactoryGirl.create :task, project: project
  end

  # POST /time_log_entries
  it 'should create new time log entry and start when no extra (time) params were provided' do
    json = api_post "time_log_entries/", {token: @user.api_key.token, time_log_entry: {task_id: @task.id} }

    response.status.should == 200
    json.has_key?('time_log_entry').should be_true
    json['time_log_entry']['running'].should == true
    TimeLogEntry.count.should == 1
    TimeLogEntry.last.started_at.should <= Time.zone.now
  end

  # POST /time_log_entries
  it 'should allow logging past time' do
    json = api_post "time_log_entries/", {token: @user.api_key.token,
           time_log_entry: {task_id: @task.id, started_at: '2000-01-01 01:00:00', stopped_at: '2000-01-01 02:00:00'} }

    json['time_log_entry']['seconds'].should == 3600
    json['time_log_entry']['running'].should == false
    TimeLogEntry.count.should == 1
  end

  # POST /time_log_entries
  it 'should deny logging time in task for project not belonging/added to user' do
    new_user = FactoryGirl.create :user
    json = api_post "time_log_entries/", {token: new_user.api_key.token, time_log_entry: {task_id: @task.id} }

    response.status.should == 404
    json.has_key?('time_log_entry').should == false
    TimeLogEntry.count.should == 0
  end

  # PUT /time_log_entries/:id
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

  # DELETE /time_log_entries/:id
  it 'should allow removing log entry and return it' do
    entry = FactoryGirl.create :time_log_entry
    -> {
      @json = api_delete "time_log_entries/#{entry.id}", {token: @user.api_key.token}
    }.should change(TimeLogEntry, :count).by(-1)

    response.status.should == 200
    @json.has_key?('time_log_entry').should be_true
    TimeLogEntry.count.should == 0
  end

  # DELETE /time_log_entries/:id
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

  # POST /time_log_entries/stop
  it 'should stop any time log entry and return stopped one' do
    entry = TimeLogEntry.new user: @user, task: @task
    entry.start
    entry.save
    entry.reload
    TimeLogEntry.where(running: true).count.should == 1

    json = api_post "time_log_entries/stop", {token: @user.api_key.token }
    TimeLogEntry.where(running: true).count.should == 0
    json['time_log_entry']['id'].should == entry.id
    json['time_log_entry']['running'].should == false
  end

  # GET /time_log_entries
  it 'should return list of all time log entries for current user' do
    (1..3).each do |i|
      FactoryGirl.create :time_log_entry, user: @user, started_at: i.hours.ago, stopped_at: (i.hours.ago + 1.minute)
    end
    TimeLogEntry.new(user: @user, task: @task).start.save!

    json = api_get "time_log_entries/", {token: @user.api_key.token }
    response.status.should == 200
    json.count.should == 4
    json.select{|tl| tl['time_log_entry']['running'] == true}.count.should == 1
  end

  # GET /time_log_entries
  it 'should filter list of time log entries by project_id' do
    FactoryGirl.create :time_log_entry, user: @user, started_at: 10.hours.ago, stopped_at: 9.hours.ago
    other_project = FactoryGirl.create :project
    other_project.identities << @user.identities.first
    other_task = FactoryGirl.create :task, project: other_project
    FactoryGirl.create :time_log_entry, user: @user, task: other_task

    @user.projects.count.should == 2
    @user.time_log_entries.count.should == 2

    json = api_get "time_log_entries/", { token: @user.api_key.token, project_id: other_project.id }
    response.status.should == 200
    json.count.should == 1
    json.first['time_log_entry']['task_id'].should == other_task.id
  end

  # GET /time_log_entries
  it 'should filter list of time log entries by start and stop time' do
    (1..5).each do |i|
      FactoryGirl.create :time_log_entry, user: @user, started_at: i.days.ago, stopped_at: (i.days.ago + 1.hour)
    end
    @user.time_log_entries.count.should == 5

    json = api_get "time_log_entries/", { token: @user.api_key.token, started_at: 10.days.ago, stopped_at: 3.days.ago }
    json.count.should == 3
  end

end
