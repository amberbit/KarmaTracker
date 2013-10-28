require 'spec_helper'

feature 'Projects management,
  as a user I can', js: true  do

  let(:user) { user = create :confirmed_user }

  let(:project1) { create(:project, name: "ZZ KarmaTracker") }
  let(:project2)  do
    proj = create(:project, name: "My sweet 16 diary :O")
    task = create :task, project: proj
    create :time_log_entry, user: user, task: task
    proj
  end
  let(:project3) { create(:project) }
  let(:project4) { create :project }

  let!(:integration) do
    integration = create(:integration, user: user)
    create(:participation, project: project1, integration: integration)
    create(:participation, project: project2, integration: integration)
    create(:participation, project: project4, integration: integration)
    integration
  end

  background do
    FakeWeb.allow_net_connect = true
    login user
  end


  scenario 'see a list of all my projects' do
    page.should have_content 'Projects'
    page.should have_content project1.name
    page.should have_content project2.name
    page.should_not have_content project3.name
    page.should have_content project4.name
  end


  scenario "filter projects by name" do
    fill_in 'searchfield', with: "karma"
    within '.view' do
      page.should have_content project1.name
      page.should_not have_content project2.name
    end
  end

  scenario 'see recent projects' do
    within '.recents.recent-projects' do
      page.should_not have_content project1.name
      page.should have_content project2.name
    end
  end

  scenario 'paginate projects with prev/next' do
    AppConfig.stub(:items_per_page).and_return(2)
    visit current_path
    within '.view' do
      page.should have_content project2.name
      page.should_not have_content project1.name
    end
    sleep 1
    within '#pagination' do
      click_on 'Next'
    end
    within '.view' do
      page.should have_content project1.name
      page.should_not have_content project2.name
    end
    within '#pagination' do
      click_on 'Previous'
    end
    within '.view' do
      page.should have_content project2.name
      page.should_not have_content project1.name
    end
    AppConfig.unstub(:items_per_page)
  end

  scenario 'paginate with dropdown' do
    AppConfig.stub(:items_per_page).and_return(2)
    visit current_path
    wait_until(10) { page.has_css?('.dropdown-toggle', visible: true) }
    find('.dropdown-toggle').click
    all('.dropdown-menu a')[1].click
    wait_until(20) { page.has_content? project1.name  }
    AppConfig.unstub(:items_per_page)
  end

  scenario 'see who else is working on my projects' do
    user2 = create :confirmed_user
    shared_task = Task.last
    TimeLogEntry.delete_all
    user2_running_entry = create :time_log_entry, user: user2, task: shared_task,
      stopped_at: nil, running: true
    my_running_entry = create :time_log_entry, user: user, task: shared_task,
      stopped_at: nil, running: true

    user3 = create :confirmed_user
    project3 = create :project
    integration3 = create(:integration, user: user3)
    create(:participation, project: project3, integration: integration3)
    create(:participation, project: project3, integration: integration)
    task3 = create :task, project: project3
    user3_running_entry = create :time_log_entry, user: user3, task: task3,
      stopped_at: nil, running: true

    visit current_path
    page.should have_content 'Currently also working'
    within '.also-working' do
      page.should have_content project2.name
      within "#project_#{project2.id}" do
        page.should_not have_css("#user_#{user.id}") #don't diplay me
        page.should have_css("#user_#{user2.id}")
        page.should have_css('img#gravatar')
      end
      page.should have_content project3.name
      within "#project_#{project3.id}" do
        page.should_not have_css("#user_#{user.id}") #don't diplay me
        page.should_not have_css("#user_#{user2.id}") #don't diplay me
        page.should have_css("#user_#{user3.id}")
        page.should have_css('img#gravatar')
      end
    end

  end

  scenario "can't see who else is working from not my projects" do
    user2 = create :confirmed_user
    different_project = create :project
    different_task = create :task, project: different_project
    TimeLogEntry.delete_all
    create :time_log_entry, user: user2, task: different_task, stopped_at: nil
    visit current_path
    wait_until(20) { page.has_no_content? 'Currently also working' }
    page.should_not have_css '.also-working'
  end

end
