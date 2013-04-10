require 'spec_helper'

describe 'Project' do

  before :each do
    @project = FactoryGirl.create :project
  end

  it 'should not allow one user to be added to a project twice' do
    @project.users.count.should == 1
    @project.users << User.last
    @project.reload.users.count.should == 1
    User.last.projects.count.should == 1
  end
end
