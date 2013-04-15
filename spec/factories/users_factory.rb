FactoryGirl.define do
  factory :user do
    sequence(:email) {|i| "user+#{i}@example.com" }
    password { 'secret123' }

    factory :admin do
      sequence(:email) {|i| "admin+#{i}@example.com" }
      after(:create) do |admin|
        admin.api_key.update_attributes({admin: true})
      end
    end

  end
end
