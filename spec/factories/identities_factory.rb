FactoryGirl.define do
  factory :identity do
    name 'Identity'
    type 'PivotalTrackerIdentity'
    sequence(:api_key) {|i| i.to_s}
    user { User.last || create(:user) }
  end
end
