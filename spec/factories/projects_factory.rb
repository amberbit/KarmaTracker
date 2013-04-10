FactoryGirl.define do
  factory :project do
    sequence(:name) {|i| "Sample project nr #{i}"}
    source_name 'PT'
    sequence(:source_identifier) {|i| i}

    users { [ User.last || create(:user) ] }
  end
end
