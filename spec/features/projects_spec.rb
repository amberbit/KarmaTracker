require 'spec_helper'

feature 'Projects management,
  as a user I can', js: true  do

  let(:user) { user = create :confirmed_user }

  let(:project1) do
    proj = create(:project, name: "ZZ KarmaTracker")
    proj.tasks << create(:task)
    proj
  end
  let(:project2) do
    proj = create(:project, name: "My sweet 16 diary :O");
    proj.tasks << create(:task)
    proj
  end
  let!(:task) do
    task = create(:task, project: project2, current_task: true, name: 'Do laundry') 
    create(:time_log_entry, task: task, user: user)
    task
  end
  let(:project3) do
    proj = create(:project);
    proj.tasks << create(:task)
    proj
  end
  let(:project4) { create :project }

  let!(:identity) do
    identity = create(:identity)
    create(:participation, project: project1, identity: identity)
    create(:participation, project: project2, identity: identity)
    create(:participation, project: project4, identity: identity)
    identity
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

  scenario 'paginate projects' do
    AppConfig.stub(:items_per_page).and_return(2)
    visit current_path
    click_on 'Next'
    page.should have_content project1.name
    AppConfig.unstub(:items_per_page)
  end

  scenario 'paginate with dropdown' do
    20.times do |i| 
      project = create(:project, source_identifier: 100+i, source_name: "Name #{i}")
      create(:participation, project: project, identity: identity)
    end
    AppConfig.stub(:items_per_page).and_return(2)
    visit current_path
    find('.dropdown-toggle').click
    find('.dropdown-menu').all('a')[6].click
    wait_until(10) { page.has_content?  'Sample project nr 20' }
    AppConfig.unstub(:items_per_page)
  end
end
