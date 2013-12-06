require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'
require 'timecop'

describe 'Tasks API' do

  before :each do
    FactoryGirl.create :integration
    FactoryGirl.create :project
    FactoryGirl.create :task
    Project.last.integrations << Integration.last
  end

  # GET /tasks/:id
  it 'should return a single task' do
    api_get "tasks/#{Task.last.id}", {token: Integration.last.user.api_key.token}
    response.status.should == 200

    project = JSON.parse(response.body)['task']
    project['id'].should == Task.last.id
    project['project_id'].should == Task.last.project_id
    project['source_name'].should == Task.last.source_name
    project['source_identifier'].should == Task.last.source_identifier
    project['current_state'].should == Task.last.current_state
    project['story_type'].should == Task.last.story_type
    project['current_task'].should == Task.last.current_task
    project['name'].should == Task.last.name
  end

  # GET /tasks/:id
  it 'should return an error message when trying to fetch non-existing task' do
    user = FactoryGirl.create :user
    expect {
      api_get "tasks/-1", {token: user.api_key.token}
    }.not_to raise_error
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Task resource not found/
  end

  # GET /tasks/:id
  it 'should return an error when trying to fetch tasks from other user\'s project' do
    user = FactoryGirl.create :user
    api_get "tasks/#{Task.last.id}", {token: user.api_key.token}
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Task resource not found/
  end

  before :each do
    project = FactoryGirl.create :project
    integration = FactoryGirl.create :integration
    project.integrations << integration
    @user = integration.user
    @task = FactoryGirl.create :task, project: project
  end


  # GET /tasks/running
  it 'should return an error when there is no current task running' do
    user = FactoryGirl.create :user
    api_get "tasks/running", {token: Integration.last.user.api_key.token}
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /"Running" resource not found/
  end

  # GET /tasks/running
  it 'should return a single running task' do
    api_post "time_log_entries/", {token: @user.api_key.token, time_log_entry: {task_id: @task.id} }
    api_get "tasks/running", {token: Integration.last.user.api_key.token}
    response.status.should == 200

    project = JSON.parse(response.body)['task']
    task = Task.last
    project['id'].should == task.id
    project['project_id'].should == task.project_id
    project['source_name'].should == task.source_name
    project['source_identifier'].should == task.source_identifier
    project['current_state'].should == task.current_state
    project['story_type'].should == task.story_type
    project['current_task'].should == task.current_task
    project['name'].should == task.name
  end

  # GET /tasks/running
  it 'should return an error when user invalid' do
    api_post "time_log_entries/", {token: @user.api_key.token, time_log_entry: {task_id: @task.id} }
    token = Integration.last.user.api_key.token
    Integration.last.user.api_key.update_attribute(:user, nil)
    api_get "tasks/running", {token: token}
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Resource not found/
  end


  it 'should return a list of 5 most recently worked on tasks' do
    TimeLogEntry.destroy_all
    Task.destroy_all
    Flex.delete_index :index => "karma_tracker_test"
    Flex.create_index :index => "karma_tracker_test"


    @tasks = []
    6.times { @tasks << create(:task) }

    wait_until(10) { TimeLogEntry::Flex.count == 0 }
    6.times do |i|
      Timecop.travel((i).days.ago) do
        create :time_log_entry, task: @tasks[5-i]
      end
    end

    api_get "tasks/recent", {token: Integration.last.user.api_key.token}
    response.status.should == 200

    tasks = JSON.parse(response.body)['tasks']
    tasks.map {|t| t["task"]["id"]}.should == @tasks.map{|t| t.id}[1..5].reverse
  end
end
