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
    wait_for_loading
    within '.top-bar-section' do
      click_link 'Archive'
    end
    within '.view' do
      wait_until(20) { page.has_content? 'Projects Archive' }
    end
  end

  scenario 'see a list of all my projects on archive page' do
    page.should have_content project1.name
    page.should have_content project2.name
    page.should_not have_content project3.name
  end

  scenario 'mark a project as archived/active' do
    participation1.should be_active
    page.has_checked_field? "#project-#{project1.id}"
    within '.view' do
      find('span', text: project1.name).click
    end

    page.has_no_checked_field? "#project-#{project1.id}"
    wait_until { participation1.reload.active? == false }

    within '.view' do
      find('span', text: project1.name).click
    end

    page.has_checked_field? "#project-#{project1.id}"
    wait_until { participation1.reload.active? == true }
  end

  scenario 'see change on projects page after changing project\'s active state' do
    participation2.should_not be_active

    page.has_no_checked_field? "#project-#{project2.id}"

    within '.view' do
      find('span', text: project2.name).click
    end

    page.has_checked_field? "#project-#{project2.id}"
    wait_until { participation2.reload.active? == true }
    visit root_path
    page.should have_content project2.name
  end
end

