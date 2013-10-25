integration ||= @integration

json.set! integration.to_snake_case do
  json.id integration.id
  json.api_key integration.api_key
  json.service integration.service_name

  if integration.is_a?(PivotalTrackerIntegration) && !integration.persisted? && !integration.valid? && (integration.email.present? || integration.password.present?)
    json.email integration.email
    json.password integration.password
  end

  if integration.is_a?(GitHubIntegration) && !integration.persisted? && !integration.valid? && (integration.username.present? || integration.password.present?)
    json.username integration.username
    json.password integration.password
  end

  unless integration.persisted? || integration.valid?
    json.errors integration.errors.messages
  end

end
