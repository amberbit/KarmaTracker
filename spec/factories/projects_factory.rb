FactoryGirl.define do
  factory :project do
    sequence(:name) {|i| "Sample project nr #{i}"}
    source_name "Pivotal Tracker"
    sequence(:source_identifier) {|i| i.to_s * 2}
    sequence(:web_hook_token) {|i| "token#{i}" }
    factory :gh_project do
      source_name 'GitHub'
    end
  end
end
