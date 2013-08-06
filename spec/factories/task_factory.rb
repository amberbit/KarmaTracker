FactoryGirl.define do
  factory :task do
    project { Project.last || FactoryGirl.create(:project) }
    source_name "Pivotal Tracker"
    sequence (:source_identifier) {|i| i.to_s}
    current_state "started"
    story_type "feature"
    sequence(:name) {|i| "Sample task nr #{i}"}
    current_task false

    factory :gh_task do
      source_name "GitHub"
      current_state "open"
      story_type "issue"
    end
  end
end
