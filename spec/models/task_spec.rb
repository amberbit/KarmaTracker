require 'spec_helper'

describe 'Task' do

  before :each do
    @user = FactoryGirl.create :user
    @task = FactoryGirl.create :task
    @task.start @user.id
  end

  it 'should store running time when stopping task' do
    sleep 1
    TimeLogEntry.where({user_id: @user.id, task_id: @task.id}).first.seconds.should == 0

    @task.stop @user.id
    TimeLogEntry.where({user_id: @user.id, task_id: @task.id}).first.seconds.should >= 1
  end

  it 'should stop all other user\'s running tasks when starting new one' do
    task = FactoryGirl.create :task
    task.start @user.id

    TimeLogEntry.where(running: true).count.should == 1
  end

end
