require 'spec_helper'
require 'timecop'

feature 'Timesheet page,
  as a user I can', js: true  do

  background do
    @time = Time.local(2013, 8, 2, 15, 0, 0)
    Timecop.travel(@time)
    @date1 =  12.hours.ago 
    @date2 = 8.hours.ago
    @date3 = 2.hours.ago
    @user = create :confirmed_user
    @project1 = create(:project, name: "KarmaTracker")
    @task1 = create(:task, project: @project1, current_task: true, name: 'Do dishes')
    @time_log_entry1 = create(:time_log_entry, task: @task1, user: @user,
                                  started_at: @date1, stopped_at: @date1 + 1.hour + 1.second)
    @project2 = create(:project, name: "My sweet 16 diary :O")
    @task2 = create(:task, project: @project2, current_task: true, name: 'Do laundry')
    @time_log_entry2 = create(:time_log_entry, task: @task2, user: @user,
                                  started_at: @date2, stopped_at: @date2 + 1.hour + 1.second)
    @time_log_entry3 = create(:time_log_entry, task: @task2, user: @user,
                                  started_at: @date3, stopped_at: @date3 + 1.hour + 1.second)
    @integration = create(:integration)
    create(:participation, project: @project1, integration: @integration)
    create(:participation, project: @project2, integration: @integration)
    FakeWeb.allow_net_connect = true
    Capybara.reset_session!
    login @user
    sleep 1
    wait_for_loading
    within '.top-bar-section' do
      click_link 'Timesheet'
    end
    within '.view' do
      wait_until(20) { page.has_content? 'Timesheet' }
    end
  end

  after(:each) { Timecop.return }

  scenario 'see all my recent time log entries with total time' do
    within '.timesheet-entries' do
      page.should have_content @project1.name
      page.should have_content @task1.name
      page.should have_content @project2.name
      page.should have_content @task2.name
      all('tbody').count.should == 3
      table_date = Date.parse(all('tbody')[0].all('td')[2].find('div').text)
      table_date.should == @time_log_entry1.started_at.localtime.to_date
      table_time = all('tbody tr')[0].all('td')[3].find('div').text
      table_time.should == '01:00 hours'
    end
    within '.timesheet-total' do
      first('td').text.should == '03:00 hours'
    end
  end

  scenario 'see a message if there is no time log entries'  do
    fill_in 'From', with: @time + 2.hours
    click_on 'search_submit'
    within '.timesheet-entries' do
      wait_until(10) { page.has_content? "There are no tracked tasks" }
    end
    within '.timesheet-total' do
      wait_until(10) { first('td').text.should == '00:00 hours' }
    end
  end

  scenario 'filter entries by project' do
    select @project1.name, from: 'Project'
    click_on 'search_submit'
    sleep 1
    within '.timesheet-entries' do
      page.should have_content @project1.name
      page.should have_content @task1.name
      wait_until(10) { page.has_no_content? @project2.name }
      page.should_not have_content @task2.name
    end
  end

  scenario 'filter entries by date' do
    fill_in 'From', with: @time_log_entry1.started_at.localtime + 2.hour
    click_on 'search_submit'
    within '.timesheet-entries' do
      page.should_not have_content @project1.name
      page.should_not have_content @task1.name
      page.should have_content @project2.name
      page.should have_content @task2.name
      wait_until(10) { all('tbody').count == 2 }
    end
    fill_in 'To', with: @time_log_entry2.started_at.localtime + 1.hour
    click_on 'search_submit'
    within '.timesheet-entries' do
      page.should_not have_content @project1.name
      page.should_not have_content @task1.name
      page.should have_content @project2.name
      page.should have_content @task2.name
      wait_until(10) { all('tbody').count == 1 }
    end
  end

  scenario 'edit entry' do
    within "#timesheet_entry_#{@time_log_entry1.id}" do
      click_on 'Edit'
      wait_until(10) { page.has_field? 'Started at' }
      fill_in 'Started at', with: (@date1 - 30.minutes).localtime
      fill_in 'Stopped at', with: (@date1 + 1.hour).localtime
      click_on 'Save'
    end
    sleep 1
    within "#timesheet_entry_#{@time_log_entry1.id}" do
      table_date = DateTime.parse(all('td')[2].find('div').text)
      expected = (@date1 - 30.minutes).localtime.to_datetime.strftime('%Y-%m-%dT%H:%M:%S')
      table_date.strftime('%Y-%m-%dT%H:%M:%S').should == expected
      table_time = all('td')[3].find('div').text
      table_time.should == '01:30 hours'
    end
    @time_log_entry1.reload.started_at.strftime('%Y-%m-%dT%H:%M:%S').should == (@date1 - 30.minutes).strftime('%Y-%m-%dT%H:%M:%S')
    @time_log_entry1.reload.stopped_at.strftime('%Y-%m-%dT%H:%M:%S').should == (@date1 + 1.hour).strftime('%Y-%m-%dT%H:%M:%S')
  end

  scenario 'delete entry' do
    TimeLogEntry.count.should == 3
    page.should have_content @project1.name
    page.should have_content @project2.name
    within "#timesheet_entry_#{@time_log_entry1.id}" do
      click_on 'Edit'
      sleep 1
      click_on 'Delete entry'
    end
    wait_until(10) { TimeLogEntry.count == 2 }
  end

  scenario 'not submit overlapping entry' do
    within "#timesheet_entry_#{@time_log_entry2.id}" do
      click_on 'Edit'
    end
    wait_until(10) { page.has_field? 'Started at' }
    fill_in 'Started at', with: (@time_log_entry1.started_at + 1.second).localtime.localtime.to_s
    click_on 'Save'
    page.should have_content 'should not overlap other time log entries'
    page.should have_field 'Started at'
    page.should have_css 'tr.error-row'
    within "#timesheet_entry_#{@time_log_entry2.id}" do
      fill_in 'Started at', with: @time_log_entry2.started_at.localtime
      fill_in 'Stopped at', with: (@time_log_entry3.started_at + 2.seconds).localtime
      click_on 'Save'
    end
    page.should have_content 'should not overlap other time log entries'
    page.should have_field 'Started at'
    page.should have_css 'tr.error-row'
  end

  scenario 'not submit entry with stopped at < started at' do
    within "#timesheet_entry_#{@time_log_entry2.id}" do
      click_on 'Edit'
      wait_until(10) { page.has_field? 'Started at' }
      fill_in 'Stopped at', with: Time.now
      fill_in 'Started at', with: Time.now + 1.second
      click_on 'Save'
      page.should have_content 'must be after start time'
      page.should have_field 'Started at'
    end
  end


  scenario 'not submit entry that is in the future' do
    within "#timesheet_entry_#{@time_log_entry2.id}" do
      click_on 'Edit'
      wait_until(10) { page.has_field? 'Started at' }
      fill_in 'Started at', with: Time.now + 1.hour
      click_on 'Save'
      page.should have_content 'should not be in the future'
      page.should have_field 'Started at'
    end
  end
end
