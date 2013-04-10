require 'spec_helper'

describe 'TimeLogEntry' do

  before :each do
    @user = FactoryGirl.create :user
  end

  context 'validaion' do
    it 'should validate start and stop times order' do
      tl = TimeLogEntry.new user: @user, started_at: 1.hours.ago, stopped_at: 2.hours.ago
      tl.valid?.should be_false
      tl.errors.full_messages.should include("Stopped at must be after start time")

      tl.stopped_at = Time.zone.now
      tl.valid?.should be_true
    end

    it 'should validate ovelapping with other time entries' do
      TimeLogEntry.create user: @user, started_at: 1.hours.ago, stopped_at: Time.zone.now
      tl = TimeLogEntry.new user: @user, started_at: 2.hours.ago, stopped_at: Time.zone.now

      tl.valid?.should be_false
      tl.errors.full_messages.should include("Stopped at should not overlap other time log entries")

      tl.stopped_at = 61.minutes.ago
      tl.valid?.should be_true
    end
  end

  it 'should stop all other user\'s running log entries when starting new one' do
    FactoryGirl.create :time_log_entry, running: true, user: @user

    tl = TimeLogEntry.new user: @user
    tl.start
    TimeLogEntry.where(running: true).count.should == 1
  end

  it 'should store running time when stopping log entry' do
    tl = TimeLogEntry.new user: @user
    tl.start
    sleep 1
    tl.stop
    tl.seconds.should >= 1
  end

end
