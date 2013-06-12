  require 'spec_helper'
  require 'timecop'

  describe Task do
    context '#recent' do
      before :each do
      @tasks = []

      10.times { @tasks << FactoryGirl.create(:task) }

      10.times do |i|
        Timecop.travel((i).days.ago) do
          FactoryGirl.create :time_log_entry, task: @tasks[9-i]
        end
      end
    end

    it 'should return a list of 5 most recent tasks' do
      Task.recent.to_a.should == @tasks[5..9].reverse
    end

    it 'should not include duplicates' do
      Timecop.travel(1.day.from_now) do
        FactoryGirl.create :time_log_entry, task: @tasks.last
      end

      Task.recent.to_a.should == @tasks[5..9].reverse
    end

    it 'should be possible to filter tasks by user' do
      first_user = User.first
      second_user = FactoryGirl.create :user

      Timecop.travel(1.day.from_now) do
        FactoryGirl.create :time_log_entry, task: @tasks.last, user: second_user
      end

      Task.recent(first_user).to_a.should == @tasks[5..9].reverse
      Task.recent(second_user).to_a.should == [@tasks.last]
    end
  end
end

