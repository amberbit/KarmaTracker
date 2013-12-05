require 'spec_helper'

describe PivotalTrackerActivityWebHook do

  before :each do
    allow_local_connect if Rails.env.test?
    @project = FactoryGirl.create :project, source_identifier: 16
    @hook = PivotalTrackerActivityWebHook.new(@project)
  end

  it 'should create new task' do
    @project.tasks.count.should == 0
    @hook.process_request File.read(Rails.root.join('spec','fixtures','pivotal_tracker','activities','story_create2.json'))

    @project.tasks.count.should == 1
    @project.tasks.last.name.should == "Build Death Star"
    @project.tasks.last.source_name.should == "Pivotal Tracker"
    @project.tasks.last.source_identifier.should == "1231231"
    @project.tasks.last.story_type.should == "feature"
    @project.tasks.last.current_state.should == "unscheduled"
    @project.tasks.last.current_task.should == false
  end

  it 'should update existing task' do
    @hook.process_request File.read(Rails.root.join('spec','fixtures','pivotal_tracker','activities','story_create2.json'))
    @project.tasks.count.should == 1
    @project.tasks.last.current_state.should == "unscheduled"
    @project.tasks.last.current_task.should == false

    @hook.process_request File.read(Rails.root.join('spec','fixtures','pivotal_tracker','activities','story_update2.json'))
    @project.tasks.count.should == 1
    @project.tasks.last.current_state.should == "started"
    @project.tasks.last.current_task.should == true
  end
end
