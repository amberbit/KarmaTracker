#encoding: UTF-8

require 'spec_helper'


feature 'Tasks management,
as a user I can', js: true  do

  let(:user) { user = create :confirmed_user }

  let!(:project1) do
    FakeWeb.allow_net_connect = true
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

  let!(:integration) do
    integration = create(:integration, user: user)
    integration = user.integrations.first
    create(:participation, project: project1, integration: integration)
    create(:participation, project: project2, integration: integration)
    integration
  end


  background do
    FakeWeb.allow_net_connect = true
    Capybara.reset_session!
    login user
  end


  scenario 'see a list of project\'s current tasks' do
    within '.view' do
      find('span', text: project1.name).click
    end
    page.should have_content task1.name
    page.should_not have_content task2.name
    page.should_not have_content task3.name
  end

  #TODO: use location.reload(true) and use poltergeist
  scenario 'stay on current page after refresh', driver: :selenium do
    within '.view' do
      find('span', text: project1.name).click
    end
    page.should have_content task1.name
    page.driver.browser.navigate.refresh
    page.should have_content task1.name
    page.driver.browser.close
  end

  scenario 'toggle current tasks' do
    within '.view' do
      find('span', text: project1.name).click
    end
    page.should_not have_content task3.name
    uncheck 'Show only current'
    page.should have_content task3.name
    check 'Show only current'
    page.should_not have_content task3.name
  end

  scenario 'filter tasks by name' do
    within '.view' do
      find('span', text: project1.name).click
    end
    page.should have_content task1.name
    page.should have_content task4.name
    fill_in 'searchfield', with: "laundry"
    page.should_not have_content task1.name
    page.should have_content task4.name
  end

  scenario 'start/stop working on task' do
    within '.view' do
      find('span', text: project1.name).click
    end
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

  scenario 'see recent tasks in right order' do
    recent_task2 = create(:task, project: project1, current_task: true, name: 'Write a blog post')
    create(:time_log_entry, task: recent_task2, user: user, started_at: 50.minutes.ago, stopped_at: 20.minutes.ago)
    visit current_path
    within '.view' do
      find('span', text: project1.name).click
    end
    within '.recents.recent-tasks' do
      page.should_not have_content task1.name
      page.body.should =~ /#{recent_task2.name}.*#{task4.name}/m
    end
  end

  #edge case which occured when default_scope in tasks was added
  scenario "don't see tasks ordered by updated at in recent" do
    updated_at_task = create(:task, project: project1, current_task: true, name: 'Old recent- but updated at now')
    create(:time_log_entry, task: updated_at_task, user: user, started_at: 50.days.ago, stopped_at: 49.days.ago)
    visit current_path
    within '.view' do
      find('span', text: project1.name).click
    end
    within '.recents.recent-tasks' do
      page.body.should =~ /#{task4.name}.*#{updated_at_task.name}/m
    end
  end

  scenario "see spining wheel when loading tasks list" do

    AppConfig.items_per_page = 1
    within '.view' do
      find('span', text: project1.name).click
    end
    wait_until(10) { page.has_content? "→ #{project1.name}" }
    uncheck 'Show only current'
    within '.loading' do 
      page.should have_content 'Loading'
    end
    AppConfig.items_per_page = 20
  end

  scenario 'paginate tasks with prev/next' do
    AppConfig.stub(:items_per_page).and_return(1)
    visit current_path
    within '.view' do
      find('span', text: project1.name).click
    end
    sleep 1
    within '.view' do
      page.should have_content task4.name
      page.should_not have_content task1.name
    end
    within '#pagination' do
      click_on 'Next'
    end
    within '.view' do
      page.should have_content task1.name
      page.should_not have_content task4.name
    end
    within '#pagination' do
      click_on 'Previous'
    end
    within '.view' do
      page.should have_content task4.name
      page.should_not have_content task1.name
    end
    AppConfig.unstub(:items_per_page)
  end

  scenario 'paginate with dropdown' do
    AppConfig.stub(:items_per_page).and_return(1)
    visit current_path
    within '.view' do
      find('span', text: project1.name).click
    end
    sleep 1
    within '.view' do
      page.should have_content task4.name
      page.should_not have_content task1.name
    end
    within '#pagination' do
      find('.dropdown-toggle').click
      #wait_until(20) { find('.dropdown-menu a', text: '2/2') }
      #all('.dropdown-menu a')[1].click
      find('.dropdown-menu a', text: '2/2').click
    end
    within '.view' do
      page.should have_content task1.name
      page.should_not have_content task4.name
    end
    AppConfig.unstub(:items_per_page)
  end


#  scenario 'see who else is working on other tasks' do
#    user2 = create :confirmed_user
#    integration2 = create(:integration, user: user2)
#    create(:participation, project: project2, integration: integration2)
#    TimeLogEntry.delete_all
#    user2_running_entry = create :time_log_entry, user: user2, task: task2,
#      stopped_at: nil, running: true
#    my_running_entry = create :time_log_entry, user: user, task: task2,
#      stopped_at: nil, running: true

#    user3 = create :confirmed_user
#    integration3 = create(:integration, user: user3)
#    create(:participation, project: project2, integration: integration)
#    task3 = create :task, project: project2, current_task: true
#    user3_running_entry = create :time_log_entry, user: user3, task: task3,
#      stopped_at: nil, running: true

#    within '.view' do
#      find('span', text: project2.name).click
#    end
#    page.should have_content 'Currently also working'
#    within '.also-working' do
#      page.should_not have_content project2.name
#      within "#task_#{task2.id}" do
#        page.should_not have_css("#user_#{user.id}") #don't diplay me
#        page.should have_css("#user_#{user2.id}")
#        page.should_not have_css("#user_#{user3.id}")
#        page.should have_css('img#gravatar')
#      end
#      within "#task_#{task3.id}" do
#        page.should_not have_css("#user_#{user.id}") #don't diplay me
#        page.should_not have_css("#user_#{user2.id}")
#        page.should have_css("#user_#{user3.id}")
#        page.should have_css('img#gravatar')
#      end
#    end
#  end
end
