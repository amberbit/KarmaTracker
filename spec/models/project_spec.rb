require 'spec_helper'

describe 'Project' do

  before :each do
    reset_fakeweb_urls
    FactoryGirl.create :integration

    @project = FactoryGirl.create :project
    @project.integrations << Integration.last
  end

  it 'should not allow one integration to be added to a project twice' do
    @project.integrations.count.should == 1
    @project.integrations << Integration.last
    @project.reload.integrations.count.should == 1
    @project.users.count.should == 1
    User.last.projects.count.should == 1
  end
end
