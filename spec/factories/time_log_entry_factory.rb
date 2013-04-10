FactoryGirl.define do
  factory :time_log_entry do
    user { User.last || FactoryGirl.create(:user) }
    started_at { 2.hours.ago }
    stopped_at { 1.hours.ago }
    seconds 3600
    running false
  end
end
