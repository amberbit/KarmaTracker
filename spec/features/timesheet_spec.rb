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
    within '.timesheet-entries' do
      page.should have_content project1.name
      page.should have_content task1.name
      page.should have_content project2.name
      page.should have_content task2.name
      all('tbody').count.should == 3
      table_date = Date.parse(all('tbody')[0].all('td')[2].find('div').text)
      table_date.should == time_log_entry1.started_at.to_date
      table_time = all('tbody tr')[0].all('td')[3].find('div').text
      table_time.should == '01:00 hours'
    end
    within '.timesheet-total' do
      first('td').text.should == '03:00 hours'
    end
  end

  scenario 'filter entries by project' do
    select project1.name, from: 'Project'
    click_on 'search_submit'
    within '.timesheet-entries' do
      page.should have_content project1.name
      page.should have_content task1.name
      page.should_not have_content project2.name
      page.should_not have_content task2.name
    end
  end

  scenario 'filter entries by date' do
    fill_in 'From', with: time_log_entry1.started_at.localtime + 2.hour
    click_on 'search_submit'
    within '.timesheet-entries' do
      page.should_not have_content project1.name
      page.should_not have_content task1.name
      page.should have_content project2.name
      page.should have_content task2.name
      all('tbody').count.should == 2
    end
    fill_in 'To', with: time_log_entry3.started_at.localtime + 1.hour
    click_on 'search_submit'
    within '.timesheet-entries' do
      page.should_not have_content project1.name
      page.should_not have_content task1.name
      page.should have_content project2.name
      page.should have_content task2.name
      all('tbody').count.should == 1
    end
  end

  scenario 'edit entry'
  scenario 'delete entry'
end
