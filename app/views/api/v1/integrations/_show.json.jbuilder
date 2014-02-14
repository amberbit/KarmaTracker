integration ||= @integration

json.id integration.id
json.api_key integration.api_key
json.service integration.service_name

if !integration.persisted? && !integration.valid? && (integration.username.present? || integration.password.present?)
  json.username integration.username
  json.password integration.password
end

unless integration.persisted? || integration.valid?
  json.errors integration.errors.messages
end
