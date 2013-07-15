namespace :user do

  desc 'update already existing users auth tokens'
  task update_auth_tokens: :environment do
    User.all.each do |user|
      user.generate_token :auth_token
      user.save
    end
  end
end
