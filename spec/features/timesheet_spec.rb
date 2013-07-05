require 'spec_helper'

feature 'Timesheet page,
  as a user I can', js: true, driver: :selenium  do


  let(:user) { user = create :user }
  let(:project1) { create(:project, name: "KarmaTracker") }
  let!(:task1) { task = create(:task, project: project1, current_task: true, name: 'Do dishes') }
  let!(:time_log_entry1) { create(:time_log_entry, task: task1, user: user,
                                  started_at: 12.hours.ago, stopped_at: 11.hours.ago) }

  let(:project2) { create(:project, name: "My sweet 16 diary :O") }
  let!(:task2) { task = create(:task, project: project2, current_task: true, name: 'Do laundry') }
  let!(:time_log_entry2) { create(:time_log_entry, task: task2, user: user) }
  let!(:time_log_entry3) { create(:time_log_entry, task: task2, user: user,
                                  started_at: 7.hours.ago, stopped_at: 6.hours.ago) }

  let!(:identity) do
    identity = create(:identity)
    create(:participation, project: project1, identity: identity)
    create(:participation, project: project2, identity: identity)
    identity
  end

  background do
    FakeWeb.allow_net_connect = true
    login user
    click_link 'Timesheet'
  end

  scenario 'see all my recent time log entries with total time' do
    within '.view' do
      page.should have_content project1.name
      page.should have_content task1.name
      page.should have_content project2.name
      page.should have_content task2.name
      table = first('table')
      table.all('tbody').count.should == 3
      table_date = Date.parse(table.first('tbody tr').all('td')[2].find('div').text)
      table_date.should == time_log_entry1.started_at.to_date
      table_time = table.first('tbody tr').all('td')[3].find('div').text
      table_time.should == '01:00 hours'

      all('table')[1].first('td').text.should == '03:00 hours'
    end


  end

  scenario 'filter entries by project' do
    select project1.name, from: 'Project'
    click_on 'search_submit'
    within '.time-log-entries' do
      page.should have_content project1.name
      page.should have_content task1.name
      page.should_not have_content project2.name
      page.should_not have_content task2.name
    end
  end

  scenario 'filter entries by date'
  scenario 'edit entry'
  scenario 'cancel edit entry'
  scenario 'delete entry'
end
