require 'spec_helper'
require 'api/api_helper'
require 'torquebox'
require 'torquebox-no-op'
require 'fakeweb'

describe 'Projects API' do

  before :each do
    FactoryGirl.create :identity
    3.times do
      FactoryGirl.create :project
      Project.last.identities << Identity.last
    end
  end

  # GET /projects
  it 'should return an array of user projects' do
    api_get 'projects', {token: Identity.last.user.api_key.token}
    response.status.should == 200
    JSON.parse(response.body).count.should == 3
  end

  # GET /projects/:id
  it 'should return a single project' do
    api_get "projects/#{Project.last.id}", {token: Identity.last.user.api_key.token}
    response.status.should == 200

    project = JSON.parse(response.body)['project']
    project['id'].should == Project.last.id
    project['name'].should == Project.last.name
    project['source_name'].should == Project.last.source_name
    project['source_identifier'].should == Project.last.source_identifier
  end

  # GET /projects/:id
  it 'should return an error when trying to fetch other user\'s project' do
    user = FactoryGirl.create :user
    api_get "projects/#{Project.last.id}", {token: user.api_key.token}
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Resource not found/
  end

  # GET /projects/refresh
  it 'should begin refreshing user\'s projects list' do
    Project.count.should == 5

    FakeWeb.register_uri(:get, 'https://www.pivotaltracker.com/services/v4/projects',
      :body => File.read(File.join(Rails.root, 'spec', 'fixtures', 'pivotal_tracker', 'responses', 'projects2.xml')),
      :status => ['200', 'OK'])
    api_get "projects/refresh", {token: ApiKey.last.token}
    response.status.should == 200

    Project.count.should == 6

    reset_fakeweb_urls
  end

  # GET /projects/:id/tasks
  it 'should return tasks for a given project' do
    2.times { Project.last.tasks << FactoryGirl.create(:task)  }
    project = FactoryGirl.create :project
    project.identities << Identity.last
    project.tasks << FactoryGirl.create(:task)
    api_get "projects/#{project.id}/tasks", {token: Identity.last.user.api_key.token}
    resp = JSON.parse(response.body)
    task = resp["tasks"].last
    task["id"] = project.tasks.last.id
    task["project_id"] = project.tasks.last.project_id
    task["source_name"] = project.tasks.last.source_name
    task["source_identifier"] = project.tasks.last.source_identifier
    task["current_state"] = project.tasks.last.current_state
    task["story_type"] = project.tasks.last.story_type
    task["name"] = project.tasks.last.name
    task["running"] = project.tasks.last.running?(Identity.last.user.id)
    resp.count.should == 1
  end

  # GET /projects/:id/tasks
  it 'should return an error when trying to fetch tasks from other user\'s proejct' do
    user = FactoryGirl.create :user
    api_get "projects/#{Project.last.id}/tasks", {token: user.api_key.token}
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Resource not found/
  end
end
