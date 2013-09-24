require 'spec_helper'

feature 'Webhook Infobox,
  as a user
  below recents box
  I can', js: true  do

  let(:user) { create :confirmed_user }
  let!(:project1) { create(:project, name: "Random project") }
  let!(:task) { create(:task, project: project1, current_task: true) }
  let!(:time_log_entry) { create(:time_log_entry, task: task, user: user) }
  let!(:identity) { create(:identity) }
  let!(:participation) { create(:participation, project: project1, identity: identity) }

  scenario 'see web hook integration info', driver: :selenium do
    FakeWeb.allow_net_connect = true
    login user
    wait_for_loading
    within '.view' do
      first('span', text: project1.name).click
    end
    wait_until(10) { page.has_content? 'WebHook Integration' }
    find_field('webhook_url')['value'] =~ /api\/v1\/projects\/#{project1.id}\/pivotal_tracker_activity_web_hook/
  end
end
