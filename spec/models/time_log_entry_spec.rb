require 'spec_helper'

describe 'TimeLogEntry' do

  before :each do
    FakeWeb.allow_net_connect = true
    @user = FactoryGirl.create :user
    @task = FactoryGirl.create :task
  end

  it 'should validate start and stop times order' do
    tl = TimeLogEntry.new user: @user, task: @task, started_at: 1.hours.ago, stopped_at: 2.hours.ago
    tl.valid?.should be_false
    tl.errors.full_messages.should include("Stopped at must be after start time")

    tl.stopped_at = Time.zone.now
    tl.valid?.should be_true
  end

  it 'should validate ovelapping with other time entries' do
    TimeLogEntry.create user: @user, task: @task, started_at: 1.hours.ago, stopped_at: Time.zone.now
    wait_until(10) { TimeLogEntry::Flex.by_user(@user.id).count == 1 }
    tl = TimeLogEntry.new user: @user, task: @task, started_at: 2.hours.ago, stopped_at: Time.zone.now

    tl.valid?.should be_false
    tl.errors.messages[:stopped_at].should include("whole entry should not contain other time log entries")

    tl.stopped_at = 61.minutes.ago
    tl.valid?.should be_true
  end

  it 'should not allow creating entry for time periods in the future' do
    tl = TimeLogEntry.create user: @user, task: @task, started_at: 1.hours.ago, stopped_at: 1.hour.from_now

    tl.valid?.should be_false
    tl.errors.full_messages.should include("Stopped at should not be in the future")
  end

  it 'should calculate seconds if stopped_at provided' do
    tl = TimeLogEntry.create user: @user, task: @task, started_at: 2.hours.ago, stopped_at: 1.hour.ago

    tl.seconds.should_not be_nil
    tl.seconds.should == 3600
  end

end
