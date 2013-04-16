FactoryGirl.define do
  factory :task do
    project { Project.last || FactoryGirl.create(:project) }
    source_name "Pivotal Tracker"
    sequence (:source_identifier) {|i| i.to_s * 8}
    current_state "started"
    story_type "feature"
    sequence(:name) {|i| "Sample task nr #{i}"}
    current_task false
  end
end
