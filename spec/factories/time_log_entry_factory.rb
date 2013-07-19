FactoryGirl.define do
  factory :time_log_entry do
    user { User.last || FactoryGirl.create(:user) }
    task { Task.last || FactoryGirl.create(:task) }
    started_at { 2.hours.ago }
    stopped_at { 1.hours.ago }
    seconds 3600
    running false

    before(:create) do |tle|
      puts "BEFORE #{tle.valid?} #{tle.errors.full_messages}"
      while(!tle.valid? && tle.errors.full_messages.find{ |e| e.include? "should not overlap other time log entries" }) do
        puts "WHILE #{tle.started_at}, #{tle.stopped_at}"
        tle.started_at = tle.started_at - 1.hour
        tle.stopped_at = tle.stopped_at - 1.hour
      end
    end
  end
end
