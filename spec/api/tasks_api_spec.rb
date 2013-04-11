require 'spec_helper'
require 'api/api_helper'

describe 'Task API' do

  before :each do
    @user = FactoryGirl.create :user
    @task = FactoryGirl.create :task
  end

  it 'should start new task' do
    api_get "tasks/#{@task.id}/start", {token: @user.api_key.token}

    @response['message'].should == 'Task started'
    @response['status'].should == 200
    @user.running_task.should == @task
  end

  it 'should not start task if other task is running' do
    @task.start @user.id

    new_task = FactoryGirl.create :task
    api_get "tasks/#{new_task.id}/start", {token: @user.api_key.token}
    @response['message'].should == 'Another task running'
    @user.running_task.should_not == new_task
  end

  it 'should not restart task if it is already running' do
    @task.start @user.id
    started_at = TimeLogEntry.first.started_at

    api_get "tasks/#{@task.id}/start", {token: @user.api_key.token}
    @response['message'].should == 'Task already running'
    TimeLogEntry.first.started_at.should == started_at
  end

  it 'should stop running task' do
    @task.start @user.id

    api_get "tasks/#{@task.id}/stop", {token: @user.api_key.token}
    @response['message'].should == 'Task stopped'
    @response['status'].should == 200
    @user.running_task.should be_nil
  end

  it 'should deny stopping not running task' do
    api_get "tasks/#{@task.id}/stop", {token: @user.api_key.token}
    @response['message'].should == 'Task not running'
  end

end
