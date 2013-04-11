FactoryGirl.define do
  factory :project do
    sequence(:name) {|i| "Sample project nr #{i}"}
    source_name 'PT'
    sequence(:source_identifier) {|i| i}

    identities { [ Identity.last || create(:identity) ] }
  end
end
