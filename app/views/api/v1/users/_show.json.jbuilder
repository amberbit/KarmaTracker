user ||= @user

json.user do
  json.id user.id
  json.email user.email

  if user.api_key
    json.token user.api_key.token
  end

  if user.api_key && @current_admin.present?
    json.admin user.api_key.admin
  end

  unless user.valid?
    json.errors user.errors.messages
  end
end
