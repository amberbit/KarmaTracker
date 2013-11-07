require 'spec_helper'

feature 'Projects archive management,
as a user I can', js: true  do
  let(:user) { create :confirmed_user }
  let(:project1) { create(:project, name: "ZZ KarmaTracker") }
  let(:project2) { create(:project) }
  let(:project3) { create(:project) }
  let!(:integration) { create(:integration, user: user) }
  let!(:participation1) { create(:participation, project: project1, integration: integration) }
  let!(:participation2) { create(:participation, project: project2, integration: integration, active: false) }
  
  background do
    FakeWeb.allow_net_connect = true
    login user
    within '.top-bar-section' do
      click_link 'Archive'
    end
    within '.view' do
      wait_until(20) { page.has_content? 'Projects Archive' }
    end
  end
  
  scenario 'see a list of all my projects' do
    page.should have_content project1.name
    page.should have_content project2.name
    page.should_not have_content project3.name
  end
  
  scenario 'mark a project as archived/active' do
    participation1.should be_active
    within '.view' do
      find('span', text: project1.name).click
    end
    participation1.should_not be_active
    within '.view' do
      find('span', text: project1.name).click
    end
    participation1.should be_active
  end
  
  scenario 'see all active projects on projects page' do
    within '.view' do
      find('span', text: project2.name).click
    end
    participation2.should be_active
    visit root_path
    page.should have_content project1.name
    page.should have_content project2.name
  end
  
  scenario 'not see any archived projects on projects page' do
    within '.view' do
      find('span', text: project1.name).click
    end
    participation1.should_not be_active
    visit root_path
    page.should_not have_content project1.name
    page.should_not have_content project2.name
  end
end
