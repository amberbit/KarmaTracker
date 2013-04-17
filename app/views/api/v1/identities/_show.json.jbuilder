identity ||= @identity

json.set! identity.to_snake_case do
  json.id identity.id
  json.name identity.name
  json.api_key identity.api_key
  json.service identity.service_name

  if @current_admin.present?
    json.user_id identity.user_id
    json.source_id identity.source_id
    json.last_projects_refresh_at identity.last_projects_refresh_at
  end

  if !identity.persisted? && !identity.valid? && (identity.email.present? || identity.password.present?)
    json.email identity.email
    json.password identity.password
  end

  unless identity.persisted? || identity.valid?
    json.errors identity.errors.messages
  end

end
