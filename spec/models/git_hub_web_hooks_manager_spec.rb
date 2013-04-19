require 'spec_helper'

describe 'GitHubWebHooksManager' do

  before :each do
    @project = FactoryGirl.create :project, source_name: 'Git Hub', source_identifier: '12345678'
    @hook_manager = GitHubWebHooksManager.new({project: @project})
  end

  it 'should create new issues' do
    @project.tasks.count.should == 0
    body = File.read(Rails.root.join('spec','fixtures','git_hub','activities','issue_open.json'))
    headers = {'X-Github-Event' => 'issues'}
    request = Object.new
    request.stub(:body).and_return body
    request.stub(:headers).and_return headers

    @hook_manager.process_feed request
    @project.tasks.count.should == 1
    @project.tasks.last.current_state.should == 'open'
  end

  it 'should update existing issue state' do
    FactoryGirl.create :gh_task, project: @project, source_identifier: "12345678/1"
    @project.tasks.count.should == 1
    body = File.read(Rails.root.join('spec','fixtures','git_hub','activities','issue_close.json'))
    headers = {'X-Github-Event' => 'issues'}
    request = Object.new
    request.stub(:body).and_return body
    request.stub(:headers).and_return headers

    @hook_manager.process_feed request
    @project.tasks.count.should == 1
    @project.tasks.last.current_state.should == 'closed'
  end

end
