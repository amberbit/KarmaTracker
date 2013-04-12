FactoryGirl.define do
  factory :project do
    sequence(:name) {|i| "Sample project nr #{i}"}
    source_name 'Pivotal Tracker'
    sequence(:source_identifier) {|i| i}
  end
end
