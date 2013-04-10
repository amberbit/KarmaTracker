FactoryGirl.define do
  factory :identity do
    name 'Identity'
    type 'PivotalTrackerIdentity'
    sequence(:api_key) {|i| i}
    user { User.last || create(:user) }
  end
end
