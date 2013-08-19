require 'spec_helper'

feature 'Projects management,
  as a user I can', js: true  do

  let(:user) { user = create :confirmed_user }

  let(:project1) { create(:project, name: "ZZ KarmaTracker") }
  let(:project2) { create(:project, name: "My sweet 16 diary :O") }
  let(:project3) { create(:project) }
  let(:project4) { create :project }

  let!(:identity) do
    identity = create(:identity, user: user)
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

  scenario 'paginate projects with prev/next' do
    AppConfig.stub(:items_per_page).and_return(2)
    visit current_path
    page.should have_content project2.name
    page.should_not have_content project1.name
    sleep 1
    within '#pagination' do
      click_on 'Next'
    end
    page.should have_content project1.name
    page.should_not have_content project2.name
    within '#pagination' do
      click_on 'Previous'
    end
    page.should have_content project2.name
    page.should_not have_content project1.name
    AppConfig.unstub(:items_per_page)
  end

  scenario 'paginate with dropdown' do
    AppConfig.stub(:items_per_page).and_return(2)
    visit current_path
    find('.dropdown-toggle').click
    all('.dropdown-menu a')[1].click
    wait_until(20) { page.has_content? project1.name  }
    AppConfig.unstub(:items_per_page)
  end
end
