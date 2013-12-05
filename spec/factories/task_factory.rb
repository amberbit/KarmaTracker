FactoryGirl.define do
  factory :task do
    project { Project.last || FactoryGirl.create(:project) }
    source_name "Pivotal Tracker"
    sequence (:source_identifier) {|i| (i+100).to_s}
    current_state "started"
    story_type "feature"
    sequence(:name) {|i| "Sample task nr #{i}"}
    current_task false
    sequence (:position) {|i| i}

    factory :gh_task do
      source_name "GitHub"
      current_state "open"
      story_type "issue"
    end
  end
end
