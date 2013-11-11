require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'
require 'timecop'

describe 'Projects API' do

  before :each do
    @integration = create :integration
    3.times do
      FactoryGirl.create :project
      Project.last.integrations << @integration
    end
  end

  # GET /projects
  it 'should return paginated array of user projects' do
    AppConfig.stub(:items_per_page).and_return(2)
    api_get 'projects?page=2', {token: Integration.last.user.api_key.token}
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp['total_count'].to_i.should == 3
    resp['projects'].count.should == 1
    AppConfig.unstub(:items_per_page)
  end

# GET /projects
  it 'should return error message when user invalid' do
    AppConfig.stub(:items_per_page).and_return(2)
    api_get 'projects?page=2', {token: Integration.last.user.api_key.token}
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp['total_count'].to_i.should == 3
    resp['projects'].count.should == 1
    AppConfig.unstub(:items_per_page)
  end

  # GET /projects?query=search_term
  it 'should return searched project' do
    integration = Integration.last
    p = create :project, name: "The next Google", integrations: [integration]
    wait_until(10) do
      Project::Flex.search_by_id_and_name('google', [p.id]).count == 1
    end
    api_get 'projects?query=google', {token: integration.user.api_key.token}
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp['projects'].count.should == 1
    project = resp['projects'].last["project"]
    project["id"] = p.id
  end

  # GET /projects/:id
  it 'should return a single project' do
    api_get "projects/#{Project.last.id}", {token: Integration.last.user.api_key.token}
    response.status.should == 200

    project = JSON.parse(response.body)['project']
    project['id'].should == Project.last.id
    project['name'].should == Project.last.name
    project['source_name'].should == Project.last.source_name
    project['source_identifier'].should == Project.last.source_identifier
  end

  # GET /projects/:id
  it 'should return an error message when trying to fetch non-existing project' do
    user = FactoryGirl.create :user
    expect {
      api_get "projects/-1", {token: user.api_key.token}
    }.not_to raise_error(ActiveRecord::RecordNotFound)
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Resource not found/
  end

  # GET /projects/:id
  it 'should return an error message when trying to fetch other user\'s project' do
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

  it "should fetch project's tasks" do
    project = Project.last
    expect {
      api_get "projects/#{project.id}/refresh_for_project", {token: ApiKey.last.token}
      response.status.should == 200
    }.to change{project.tasks.count}.by(2)
  end

  it "should not fetch tasks from not my project" do
    project = Project.last
    expect {
      user = FactoryGirl.create :user
      api_get "projects/#{project.id}/refresh_for_project", {token: user.api_key.token}
      response.status.should == 404
      resp = JSON.parse(response.body)
      resp.should have_key("message")
      resp["message"].should =~ /Resource not found/
    }.not_to change{project.tasks.count}.by(2)
  end

  # GET /projects/:id/tasks
  it 'should return paginated tasks for a given project' do
    AppConfig.stub(:items_per_page).and_return(2)
    project = Project.last
    3.times { project.tasks << create(:task)  }
    t = Task.last
    api_get "projects/#{project.id}/tasks?page=2", {token: @integration.user.api_key.token}
    resp = JSON.parse(response.body)
    resp['total_count'].should == 3
    resp['tasks'].count.should == 1
    task = resp['tasks'].last["task"]
    task["id"] = t.id
    task["project_id"] = t.project_id
    task["source_name"] = t.source_name
    task["source_identifier"] = t.source_identifier
    task["current_state"] = t.current_state
    task["story_type"] = t.story_type
    task["name"] = t.name
    task["current_task"] = t.current_task
    task["running"] = Task.running?(t.id, @integration.user.id)
    AppConfig.unstub(:items_per_page)
  end

  it 'should return tasks for a given project with search param' do
    project = Project.last
    t = FactoryGirl.create(:task, name: "Do 100 pushups", project: project)
    wait_until(10) do
      Task::Flex.search_by_id_and_name('pushups', [t.id]).count == 1
    end
    api_get "projects/#{project.id}/tasks?query=push", {token: Integration.last.user.api_key.token}
    resp = JSON.parse(response.body)
    resp['tasks'].count.should == 1
    task = resp['tasks'].last["task"]
    task["id"] = t.id
    task["project_id"] = t.project_id
    task["source_name"] = t.source_name
    task["source_identifier"] = t.source_identifier
    task["current_state"] = t.current_state
    task["story_type"] = t.story_type
    task["name"] = t.name
    task["current_task"] = t.current_task
    task["running"] = false
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
    api_get "projects/#{Project.last.id}/current_tasks", {token: Integration.last.user.api_key.token}
    response.status.should == 200
    resp = JSON.parse(response.body)
    task = resp['tasks'].last["task"]
    task["id"] = t.id
    task["project_id"] = t.project_id
    task["source_name"] = t.source_name
    task["source_identifier"] = t.source_identifier
    task["current_state"] = t.current_state
    task["story_type"] = t.story_type
    task["name"] = t.name
    task["current_task"] = t.current_task
    task["running"] = Task.running?(t.id, Integration.last.user.id)
    resp['tasks'].count.should == 1
  end

  # GET /projects/:id/current_tasks
  it 'should return an error message when trying to fetch tasks from other user\'s project' do
    user = FactoryGirl.create :user
    api_get "projects/#{Project.last.id}/current_tasks", {token: user.api_key.token}
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Resource not found/
  end

  # GET /projects/:id/current_tasks
  it 'should return an error message when trying to fetch tasks from non-existing project' do
    user = FactoryGirl.create :user
    expect {
      api_get "projects/-1/current_tasks", {token: user.api_key.token}
    }.not_to raise_error(ActiveRecord::RecordNotFound)
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

  # GET /api/v1/projects/:id/pivotal_tracker_activity_web_hook_url
  it 'should return an error when trying to get PT from non-existing project' do
    user = create :user
    api_get "projects/#{'non-existing'}/pivotal_tracker_activity_web_hook_url", {token: user.api_key.token}
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


  it 'should return a list of 5 most recently worked on projects' do
    Project.destroy_all
    TimeLogEntry.destroy_all
    Task.destroy_all

    @projects = []
    10.times { @projects << FactoryGirl.create(:project) }


    @tasks = []
    10.times do |i|
      @tasks << FactoryGirl.create(:task, project: @projects[i])
    end

    10.times do |i|
      Timecop.travel((i).days.ago) do
        FactoryGirl.create :time_log_entry, task: @tasks[9-i]
      end
    end
    api_get "projects/recent", {token: Integration.last.user.api_key.token}
    response.status.should == 200

    projects = JSON.parse(response.body)['projects']
    projects.map {|p| p["project"]["id"]}.should == @projects.map{|p| p.id}[5..9].reverse
  end

  it 'should not get url of github project' do
    integration = create :git_hub_integration
    project = create :gh_project, integrations: [integration]
    api_get "projects/#{project.id}/pivotal_tracker_activity_web_hook_url", {token: project.users.last.api_key.token}
    response.status.should == 404
    resp = JSON.parse(response.body)
    resp.should have_key("message")
    resp["message"].should =~ /Resource not found/
  end


  # GET /api/v1/projects/also_working
  it 'should not find any projects when all are destroyed' do
    @integration = Integration.last
    @integration.projects.destroy_all
    api_get "projects/also_working", {token: @integration.user.api_key.token}
    response.status.should == 204
    response.body.should be_empty
  end

  # GET /api/v1/projects/also_working
  it 'should not find any projects for invalid user' do
    @integration = Integration.last
    @integration.user.delete
    expect {
      api_get "projects/also_working", {token: @integration.user.api_key.token}
    }.not_to raise_error
    response.status.should == 204
    response.body.should be_empty
  end
  
  # PUT /api/v1/projects/:id/toggle_active
  it 'should toggle project\'s active state for current user' do
    project = Project.last
    project.should be_active_for_user(Integration.last.user)
    api_put "projects/#{project.id}/toggle_active", {token: Integration.last.user.api_key.token}
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp['project'].should have_key("active")
    resp['project']['active'].should == false
    project.reload.should_not be_active_for_user(Integration.last.user)
  end 
end
