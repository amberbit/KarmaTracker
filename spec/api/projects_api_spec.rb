require 'spec_helper'
require 'api/api_helper'

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
    response.code.should == '200'
    JSON.parse(response.body).count.should == 3
  end

  # GET /project/:id
  it 'should return a single project' do
    api_get "projects/#{Project.last.id}", {token: Identity.last.user.api_key.token}
    response.code.should == '200'

    project = JSON.parse(response.body)['project']
    project['id'].should == Project.last.id
    project['name'].should == Project.last.name
    project['source_name'].should == Project.last.source_name
    project['source_identifier'].should == Project.last.source_identifier
  end

  it 'should return an error when truing to fetch other user\'s project' do
    user = FactoryGirl.create :user
    api_get "projects/#{Project.last.id}", {token: user.api_key.token}
    response.code.should == '404'
    response.body.should =~ /Resource not found/
  end
end
