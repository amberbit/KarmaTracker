require 'spec_helper'
require 'api/api_helper'

describe 'Admin API #Users' do

  before :each do
    @admin = FactoryGirl.create :admin
    3.times do
      user = FactoryGirl.create :user
      3.times do
        FactoryGirl.create(:identity, user: user, type: ["PivotalTrackerIdentity", "GitHubIdentity"].sample)
      end
    end
  end

  # GET /api/v1/admin/users
  it 'should return all users if provided valid admin API token' do
    json = api_get 'admin/users', {token: @admin.api_key.token}

    response.status.should == 200
    json.has_key?('users').should be_true
    json['users'].count.should == User.count
    json['users'].select{ |user| user['admin']==false }.count.should == 3
  end

  # GET /api/v1/admin/users
  it 'should deny admin API access when providing not admin token' do
    invalid_token = ApiKey.where(admin: false).first.token
    json = api_get 'admin/users', {token: invalid_token}

    json.has_key?('users').should be_false
    response.status.should == 401
  end

  # GET /api/v1/admin/users/:id
  it 'should return user with extra information if get via admin API' do
    invalid_key = ApiKey.where(admin: false).first

    json = api_get 'user', {token: invalid_key.token}
    json['user'].has_key?('admin').should be_false

    json = api_get "admin/users/#{invalid_key.user.id}", {token: @admin.api_key.token}
    json['user'].has_key?('admin').should be_true
  end

  # POST /api/v1/admin/users
  it 'should allow admins to create new users and apply all validation rules' do
    -> {
      @json = api_post 'admin/users', {user: {email: 'foo@bar.com', password: 'secret123'}, token: @admin.api_key.token}
    }.should change(User, :count).by(1)

    response.status.should == 200
    @json.has_key?('user').should be_true
    @json['user']['id'].should == User.last.id

    json = api_post 'admin/users', {user: {email: 'foo@bar.com', password: '123'}, token: @admin.api_key.token}
    response.status.should == 422

    json['user'].has_key?('errors').should be_true
    json['user']['errors']['email'].include?('has already been taken').should be_true
    json['user']['errors']['password'].include?('is too short (minimum is 8 characters)').should be_true
  end

  # PUT /api/v1/admin/users/:id
  it 'should allow admins to edit user' do
    user = ApiKey.where(admin: false).first.user

    json = api_put "admin/users/#{user.id}", {user: {email: 'foo@bar.com'}, token: @admin.api_key.token}
    user.reload
    json['user']['email'].should == user.email
  end

  # DELETE /api/v1/admin/users/:id
  it 'should allow admins to delete any user' do
    user = ApiKey.where(admin: false).first.user

    -> {
      json = api_delete "admin/users/#{user.id}", {token: @admin.api_key.token}
    }.should change(User, :count).by(-1)
    response.status.should == 200
  end

end
