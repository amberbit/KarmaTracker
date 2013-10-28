FactoryGirl.define do
  factory :integration do
    type 'PivotalTrackerIntegration'
    sequence(:api_key) {|i| i.to_s}
    sequence(:source_id) {|i| i.to_s}
    user { User.last || create(:user) }

    factory :git_hub_integration do
      type 'GitHubIntegration'
    end

  end
end
