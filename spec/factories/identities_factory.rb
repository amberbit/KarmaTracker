FactoryGirl.define do
  factory :identity do
    name 'Identity'
    api_key '42'
    user { User.last || create(:user) }
  end
end
