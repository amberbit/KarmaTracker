FactoryGirl.define do
  factory :user do
    sequence(:email) {|i| "user+#{i}@example.com" }
    password { 'secret123' }
    after(:create) { |user| user.update_column :confirmation_token, nil }
  end
end
