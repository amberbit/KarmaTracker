FactoryGirl.define do
  factory :user do
    sequence(:email) {|i| "user+#{i}@example.com" }
    password { 'secret123' }

    factory :confirmed_user do
      after(:create) { |user| user.update_column :confirmation_token, nil }
    end
  end
end
