require 'spec_helper'


feature 'Tasks management,
as a user I can', js: true  do

  let(:project1) do
    proj = create(:project, name: "KarmaTracker")
    proj
  end
  let!(:task1) { create(:task, project: project1, current_task: true) }
  let!(:task3) { create(:task, project: project1) }
  let!(:task4) { create(:task, project: project1, current_task: true, name: 'Do laundry') }

  let(:project2) do
    proj = create(:project, name: "My sweet 16 diary :O");
    proj
  end
  let!(:task2) { create(:task, project: project2, current_task: true) }

  let(:user) do
    user = create :user
    user.identities << create(:identity)
    identity = user.identities.first
    create(:participation, project: project1, identity: identity)
    create(:participation, project: project2, identity: identity)
    user
  end


  background do
    FakeWeb.allow_net_connect = true
    login user
    find('span', text: project1.name).click
  end


  scenario 'see a list of project\'s current tasks' do
    page.should have_content task1.name
    page.should_not have_content task2.name
    page.should_not have_content task3.name
  end

  scenario 'toggle current tasks' do
    page.should_not have_content task3.name
    uncheck 'Show only current'
    page.should have_content task3.name
    check 'Show only current'
    page.should_not have_content task3.name
  end

  scenario 'filter tasks by name' do
    page.should have_content task1.name
    page.should have_content task4.name
    fill_in 'searchfield', with: "laundry"
    page.should_not have_content task1.name
    page.should have_content task4.name
  end

  scenario 'start/stop working on task', driver: :selenium do
    within '.view' do
      span = find('span', text: task1.name)
      div = span.first(:xpath,"..").first(:xpath,"..")
      div[:class].should_not include 'running'
      span.click
      div[:class].should_not include 'running'
    end
    within '.recents.tasks' do
      span = find('span', text: task1.name)
      div = span.first(:xpath,"..").first(:xpath,"..")
      div[:class].should include 'running'
    end
    task1.time_log_entries.count.should == 1
    task1.time_log_entries.first.running.should be_true
    within '.view' do
      span = find('span', text: task1.name)
      span.click
      wait_until(10) { !span.first(:xpath,"..").first(:xpath,"..")[:class].include?('running') }
    end
    within '.recents.tasks' do
      span = find('span', text: task1.name)
      div = span.first(:xpath,"..").first(:xpath,"..")
      div[:class].should_not include 'running'
    end
    task1.time_log_entries.first.running.should be_false
  end
end
