require 'spec_helper'

feature 'Home page,
as a user I can', js: true do

  let(:user) { create :confirmed_user }
  let(:project1) { create(:project, name: "ZZ KarmaTracker") }
  let!(:integration) do
    integration = create(:integration, user: user)
    create(:participation, project: project1, integration: integration)
  end

  background do
    FakeWeb.allow_net_connect = true
    login user
  end

  scenario 'click on logo and be redirected to projects page' do
    page.should have_content project1.name
    within '.top-bar' do
      find('li.name a').click
    end
    page.should have_content project1.name
  end

  scenario 'visit root path and be redirected to projects page' do
    page.should have_content project1.name
    visit '/#/'
    page.should have_content project1.name
  end
end
