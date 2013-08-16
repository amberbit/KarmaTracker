user ||= @user

json.user do
  json.id user.id
  json.email user.email

  if user.api_key
    json.token user.api_key.token
  end
  
  json.refreshing_projects user.refreshing_projects
  json.gravatar_url user.gravatar_url
  
  unless user.valid?
    json.errors user.errors.messages
  end
end
