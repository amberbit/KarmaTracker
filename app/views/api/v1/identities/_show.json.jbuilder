identity ||= @identity

json.set! identity.to_snake_case do
  json.id identity.id
  json.name identity.name
  json.api_key identity.api_key
  json.service identity.service_name

  if identity.is_a?(PivotalTrackerIdentity) && !identity.persisted? && !identity.valid? && (identity.email.present? || identity.password.present?)
    json.email identity.email
    json.password identity.password
  end

  if identity.is_a?(GitHubIdentity) && !identity.persisted? && !identity.valid? && (identity.username.present? || identity.password.present?)
    json.username identity.username
    json.password identity.password
  end

  unless identity.persisted? || identity.valid?
    json.errors identity.errors.messages
  end

end
