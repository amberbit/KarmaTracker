require 'spec_helper'
require 'api/api_helper'
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
    t = FactoryGirl.create(:task)
    project.tasks << t
    api_get "projects/#{project.id}/tasks", {token: Identity.last.user.api_key.token}
    resp = JSON.parse(response.body)
    task = resp.last["task"]
    task["id"] = t.id
    task["project_id"] = t.project_id
    task["source_name"] = t.source_name
    task["source_identifier"] = t.source_identifier
    task["current_state"] = t.current_state
    task["story_type"] = t.story_type
    task["name"] = t.name
    task["current_task"] = t.current_task
    task["running"] = t.running?(Identity.last.user.id)
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

  # GET /projects/:id/current_tasks
  it 'should return current tasks for a given project' do
    t = FactoryGirl.create(:task, current_task: true)
    Project.last.tasks << t
    2.times { Project.last.tasks << FactoryGirl.create(:task, current_task: false) }
    api_get "projects/#{Project.last.id}/current_tasks", {token: Identity.last.user.api_key.token}
    response.status.should == 200
    resp = JSON.parse(response.body)
    task = resp.last["task"]
    task["id"] = t.id
    task["project_id"] = t.project_id
    task["source_name"] = t.source_name
    task["source_identifier"] = t.source_identifier
    task["current_state"] = t.current_state
    task["story_type"] = t.story_type
    task["name"] = t.name
    task["current_task"] = t.current_task
    task["running"] = t.running?(Identity.last.user.id)
    resp.count.should == 1
  end

  # GET /projects/:id/current_tasks
  it 'should return an error when trying to fetch tasks from other user\'s project' do
    user = FactoryGirl.create :user
    api_get "projects/#{Project.last.id}/current_tasks", {token: user.api_key.token}
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Resource not found/
  end

  # POST /api/v1/projects/git_hub_activity_web_hook
  it 'should process issues feed from GH' do
    project = FactoryGirl.create :gh_project
    json = api_post "projects/git_hub_activity_web_hook", {token: project.web_hook_token}
    response.status.should == 200
    json['message'].should == 'Activity processed'
  end

  # POST /api/v1/projects/git_hub_activity_web_hook
  it 'should not process issues feed when provided invalid token' do
    json = api_post "projects/git_hub_activity_web_hook", {token: Project.last.web_hook_token}
    response.status.should == 401
    json['message'].should == 'Invalid token'
  end

  # GET /api/v1/projects/:id/pivotal_tracker_activity_web_hook_url
  it 'should return project\'s PT web hook URL for project members' do
    api_get "projects/#{Project.last.id}/pivotal_tracker_activity_web_hook_url", {token: Project.last.users.last.api_key.token}
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp.should have_key("url")
    resp["url"].should == "#{pivotal_tracker_activity_web_hook_api_v1_project_url(Project.last)}?token=#{Project.last.web_hook_token}"
  end

  # GET /api/v1/projects/:id/pivotal_tracker_activity_web_hook_url
  it 'should return an error when trying to get PT web hook url from other user\'s project' do
    user = FactoryGirl.create :user
    api_get "projects/#{Project.last.id}/pivotal_tracker_activity_web_hook_url", {token: user.api_key.token}
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Resource not found/
  end

  # POST /api/v1/projects/:id/pivotal_tracker_activity_web_hook
  it 'should return 401 if no token was provided' do
    api_post "projects/#{Project.last.id}/pivotal_tracker_activity_web_hook", File.read(Rails.root.join('spec','fixtures','pivotal_tracker','activities','story_create.xml'))
    response.status.should == 401
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Invalid token/
  end

  # POST /api/v1/projects/:id/pivotal_tracker_activity_web_hook
  it 'should return 401 if wrong token was provided' do
    project = FactoryGirl.create :project
    project2 = FactoryGirl.create :project
    api_post "projects/#{project.id}/pivotal_tracker_activity_web_hook?token=#{project2.web_hook_token}", File.read(Rails.root.join('spec','fixtures','pivotal_tracker','activities','story_create.xml'))
    response.status.should == 401
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Invalid token/
  end

  # POST /api/v1/projects/:id/pivotal_tracker_activity_web_hook
  it 'should return 404 in case of project_id and activity data mismatch' do
    project = FactoryGirl.create :project, source_identifier: 42
    api_post "projects/#{project.id}/pivotal_tracker_activity_web_hook?token=#{project.reload.web_hook_token}", File.read(Rails.root.join('spec','fixtures','pivotal_tracker','activities','story_create.xml'))
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Resource not found/
  end

  # POST /api/v1/projects/:id/pivotal_tracker_activity_web_hook
  it 'should process correct request' do
    project = FactoryGirl.create :project, source_identifier: 16
    project.tasks.count.should == 0
    api_post "projects/#{project.id}/pivotal_tracker_activity_web_hook?token=#{project.reload.web_hook_token}", File.read(Rails.root.join('spec','fixtures','pivotal_tracker','activities','story_create.xml'))
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Activity processed/
    project.reload.tasks.count.should == 1
  end
end
