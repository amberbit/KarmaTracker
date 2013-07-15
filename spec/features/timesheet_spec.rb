require 'spec_helper'

feature 'Timesheet page,
  as a user I can', js: true  do

  let(:date1) { 12.hours.ago }
  let(:date2) { 8.hours.ago }
  let(:date3) { 2.hours.ago }

  let(:user) { user = create :confirmed_user }
  let(:project1) { create(:project, name: "KarmaTracker") }
  let!(:task1) { task = create(:task, project: project1, current_task: true, name: 'Do dishes') }
  let!(:time_log_entry1) { create(:time_log_entry, task: task1, user: user,
                                  started_at: date1, stopped_at: date1 + 1.hour) }

  let(:project2) { create(:project, name: "My sweet 16 diary :O") }
  let!(:task2) { task = create(:task, project: project2, current_task: true, name: 'Do laundry') }
  let!(:time_log_entry2) { create(:time_log_entry, task: task2, user: user,
                                  started_at: date2, stopped_at: date2 + 1.hour) }
  let!(:time_log_entry3) { create(:time_log_entry, task: task2, user: user,
                                  started_at: date3, stopped_at: date3 + 1.hour) }

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
    fill_in 'From', with: time_log_entry1.started_at.localtime - 2.hour
    click_on 'search_submit'
  end


  scenario 'see all my recent time log entries with total time' do
    within '.timesheet-entries' do
      page.should have_content project1.name
      page.should have_content task1.name
      page.should have_content project2.name
      page.should have_content task2.name
      all('tbody').count.should == 3
      table_date = Date.parse(all('tbody')[0].all('td')[2].find('div').text)
      table_date.should == time_log_entry1.started_at.localtime.to_date
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
    fill_in 'To', with: time_log_entry2.started_at.localtime + 1.hour
    click_on 'search_submit'
    within '.timesheet-entries' do
      page.should_not have_content project1.name
      page.should_not have_content task1.name
      page.should have_content project2.name
      page.should have_content task2.name
      wait_until(10) { all('tbody').count == 1 }
    end
  end

  scenario 'edit entry' do
    fill_in 'From', with: date1 - 1.hour
    click_on 'search_submit'
    date = 5.hours.ago
    sleep 1
    within "#timesheet_entry_#{time_log_entry1.id}" do
      click_on 'Edit'
      wait_until(10) { page.has_field? 'Started at' }
      fill_in 'Started at', with: (date - 30.minutes).localtime
      fill_in 'Stopped at', with: (date + 1.hour).localtime
      click_on 'Save'
    end
    sleep 1
    within "#timesheet_entry_#{time_log_entry1.id}" do
      table_date = DateTime.parse(all('td')[2].find('div').text)
      expected = (date - 30.minutes).localtime.to_datetime.strftime('%Y-%m-%dT%H:%M:%S')
      table_date.strftime('%Y-%m-%dT%H:%M:%S').should == expected
      table_time = all('td')[3].find('div').text
      table_time.should == '01:30 hours'
    end
    time_log_entry1.reload.started_at.strftime('%Y-%m-%dT%H:%M:%S').should == (date - 30.minutes).strftime('%Y-%m-%dT%H:%M:%S')
    time_log_entry1.reload.stopped_at.strftime('%Y-%m-%dT%H:%M:%S').should == (date + 1.hour).strftime('%Y-%m-%dT%H:%M:%S')
  end

  scenario 'delete entry' do
    TimeLogEntry.count.should == 3
    page.should have_content project1.name
    page.should have_content project2.name
    within "#timesheet_entry_#{time_log_entry1.id}" do
      click_on 'Edit'
      sleep 1
      click_on 'Delete entry'
    end
    wait_until(10) { TimeLogEntry.count == 2 }
  end
end
