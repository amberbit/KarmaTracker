#encoding: UTF-8

require 'spec_helper'


feature 'Tasks management,
as a user I can', js: true  do

  let(:user) { user = create :confirmed_user }

  let!(:project1) do
    proj = create(:project, name: "KarmaTracker")
    proj
  end
  let!(:task1) { create(:task, project: project1, current_task: true) }
  let!(:task3) { create(:task, project: project1) }
  let!(:task4) do
    task = create(:task, project: project1, current_task: true, name: 'Do laundry') 
    create(:time_log_entry, task: task, user: user)
    task
  end

  let(:project2) do
    proj = create(:project, name: "My sweet 16 diary :O");
    proj
  end
  let!(:task2) { create(:task, project: project2, current_task: true) }

  let!(:identity) do
    identity = create(:identity, user: user)
    identity = user.identities.first
    create(:participation, project: project1, identity: identity)
    create(:participation, project: project2, identity: identity)
    identity
  end


  background do
    FakeWeb.allow_net_connect = true
    login user
    
  end


  scenario 'see a list of project\'s current tasks' do
    find('span', text: project1.name).click
    page.should have_content task1.name
    page.should_not have_content task2.name
    page.should_not have_content task3.name
  end

  scenario 'toggle current tasks' do
    find('span', text: project1.name).click
    page.should_not have_content task3.name
    uncheck 'Show only current'
    page.should have_content task3.name
    check 'Show only current'
    page.should_not have_content task3.name
  end

  scenario 'filter tasks by name' do
    find('span', text: project1.name).click
    page.should have_content task1.name
    page.should have_content task4.name
    fill_in 'searchfield', with: "laundry"
    page.should_not have_content task1.name
    page.should have_content task4.name
  end

  scenario 'start/stop working on task' do
    find('span', text: project1.name).click
    within '.view' do
      div = find "#time-log-entry-#{task1.id}"
      div[:class].should_not include 'running'
      div.click
      wait_until(20) { div[:class].include?('running') }
    end
    within '.recents.recent-tasks' do
      div = find "#recent-time-log-entry-#{task1.id}"
      wait_until(20) { div[:class].include?('running') }
    end
    sleep 1
    task1.time_log_entries.count.should == 1
    task1.time_log_entries.first.running.should be_true
    within '.view' do
      div = find "#time-log-entry-#{task1.id}"
      div.click
      wait_until(20) { !div[:class].include?('running') }
    end
    within '.recents.recent-tasks' do
      div = find "#recent-time-log-entry-#{task1.id}"
      wait_until(20) { !div[:class].include? 'running' }
    end
    task1.time_log_entries.first.running.should be_false
  end

  scenario 'see recent tasks' do
    find('span', text: project1.name).click
    within '.recents.recent-tasks' do
      page.should_not have_content task1.name
      page.should have_content task4.name
    end
  end
  
  scenario "see spining wheel when loading task list's" do
    100.times { create(:task, project: project1) }
    find('span', text: project1.name).click
    wait_until(10) { page.has_content? "→ #{project1.name}" }
    within '.loading' do 
      page.should have_content 'Loading'
    end
  end
  
end
