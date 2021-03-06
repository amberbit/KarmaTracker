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

  scenario 'see web hook integration info' do
    FakeWeb.allow_net_connect = true
    login user
    sleep 1
    wait_for_loading
    within '.view' do
      wait_until(10) { page.has_content? project1.name }
      find('span', text: project1.name).click
    end
    wait_until(10) { page.has_content? 'WebHook Integration' }
    find_field('webhook_url')['value'] =~ /api\/v1\/projects\/#{project1.id}\/pivotal_tracker_activity_web_hook/
  end
end
