user ||= @user

json.user do
  json.id user.id
  json.email user.email

  if user.api_key
    json.token user.api_key.token
  end

  unless user.valid?
    json.errors user.errors.messages
  end
end
