require 'spec_helper'

describe 'Project' do

  before :each do
    @project = FactoryGirl.create :project
    @project.integrations << FactoryGirl.create(:integration)
  end

  it 'should not allow one integration to be added to a project twice' do
    @project.integrations.count.should == 1
    @project.integrations << Integration.last
    @project.reload.integrations.count.should == 1
    @project.users.count.should == 1
    User.last.projects.count.should == 1
  end
end
