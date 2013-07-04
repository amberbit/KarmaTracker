require 'spec_helper'


feature 'Projects management', js: true  do

  let(:project1) do
    proj = create(:project, name: "KarmaTracker")
    proj.tasks << create(:task)
    proj
  end
  let(:project2) do
    proj = create(:project, name: "My sweet 16 diary :O");
    proj.tasks << create(:task)
    proj
  end
  let(:project3) do
    proj = create(:project);
    proj.tasks << create(:task)
    proj
  end
  let(:user) do
    user = create :user
    user.identities << create(:identity)
    identity = user.identities.first
    create(:participation, project: project1, identity: identity)
    create(:participation, project: project2, identity: identity)
    user
  end

  background do
    FakeWeb.allow_net_connect = true
    login user
  end


  scenario 'do see a list of my projects' do
    page.should have_content 'Projects'
    page.should have_content project1.name
    page.should have_content project2.name
    page.should_not have_content project3.name
  end


  scenario "don't see projects without tasks" do
    project4 = create :project
    identity = user.identities.first
    create(:participation, project: project4, identity: identity)
    page.should_not have_content project4.name
  end

  scenario "filter projects by name" do
    fill_in 'searchfield', with: "karma"
    page.should have_content project1.name
    page.should_not have_content project2.name
  end
end
