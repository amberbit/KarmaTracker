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
    response.body.should =~ /Resource not found/
  end

  # GET /Projects/refresh
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
end
