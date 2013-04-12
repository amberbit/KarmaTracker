require 'spec_helper'
require 'api/api_helper'

describe 'Task API' do

  before :each do
    @user = FactoryGirl.create :user
    @task = FactoryGirl.create :task
  end

  it 'should start new task and return it' do
    json = api_get "tasks/#{@task.id}/start", {token: @user.api_key.token}

    response.status.should == 200
    json.has_key?('task').should be_true
    json['task']['running'].should be_true
    @user.running_task.should == @task
  end

  it 'should not start task if other task is running' do
    @task.start @user.id

    new_task = FactoryGirl.create :task
    json = api_get "tasks/#{new_task.id}/start", {token: @user.api_key.token}

    json['task']['running'].should be_false
    @user.running_task.should_not == new_task
  end

  it 'should stop running task' do
    @task.start @user.id

    json = api_get "tasks/#{@task.id}/stop", {token: @user.api_key.token}

    json['task']['running'].should be_false
    @user.running_task.should be_nil
  end

end
