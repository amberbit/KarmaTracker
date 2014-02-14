require 'spec_helper'

feature 'Webhook Infobox,
  as a user
  below recents box
  I can', js: true  do

  let(:user) { create :confirmed_user }
  let!(:project1) do
    FakeWeb.allow_net_connect = true
    create(:project, name: "Random project")
  end
  let!(:task) { create(:task, project: project1, current_task: true) }
  let!(:time_log_entry) { create(:time_log_entry, task: task, user: user) }
  let!(:integration) { create(:integration) }
  let!(:participation) { create(:participation, project: project1, integration: integration) }

  background do
    FakeWeb.allow_net_connect = true
    login user
  end

  scenario 'see web hook integration info' do
    within '.view' do
      wait_until(10) { page.has_content? project1.name }
      find('span', text: project1.name).click
    end
    wait_until(10) { page.has_content? 'WebHook Integration' }
    find_field('webhook_url')['value'] =~ /api\/v1\/projects\/#{project1.id}\/pivotal_tracker_activity_web_hook/
  end

  scenario "can see button for creating webhook integration if project doesn't have it" do
    within '.view' do
      find('span', text: project1.name).click
    end
    project1.web_hook_exists == false
    find('.tiny-webhook').should have_content('Create one-click WebHook Integration')
  end

end
