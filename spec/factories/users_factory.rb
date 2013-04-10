FactoryGirl.define do
  factory :user do
    sequence(:email) {|i| "user+#{i}@example.com" }
    api_key { ApiKey.create! }
    password { 'secret' }
  end
end
