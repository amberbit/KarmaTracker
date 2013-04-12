require 'spec_helper'

describe 'Project' do

  before :each do
    @project = FactoryGirl.create :project
    @project.identities << FactoryGirl.create(:identity)
  end

  it 'should not allow one identity to be added to a project twice' do
    @project.identities.count.should == 1
    @project.identities << Identity.last
    @project.reload.identities.count.should == 1
    @project.users.count.should == 1
    User.last.projects.count.should == 1
  end
end
