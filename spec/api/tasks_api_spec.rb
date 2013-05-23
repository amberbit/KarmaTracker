require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'

describe 'Tasks API' do

  before :each do
    FactoryGirl.create :identity
    FactoryGirl.create :project
    FactoryGirl.create :task
    Project.last.identities << Identity.last
  end

  # GET /tasks/:id
  it 'should return a single task' do
    api_get "tasks/#{Task.last.id}", {token: Identity.last.user.api_key.token}
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
  it 'should return an error when trying to fetch tasks from other user\'s project' do
    user = FactoryGirl.create :user
    api_get "tasks/#{Task.last.id}", {token: user.api_key.token}
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Resource not found/
  end
end
