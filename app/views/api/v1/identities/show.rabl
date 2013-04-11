object @identity => :identity
attributes :id, :name, :api_key
node(:service) {|identity| identity.service_name }

node(:api_key, if: lambda{ |i| !i.valid? && i.api_key.present? }) do |i|
  i.api_key
end
node(:email, if: lambda{ |i| !i.valid? && i.email.present? }) do |i|
  i.email
end
node(:password, if: lambda{ |i| !i.valid? && i.password.present? }) do |i|
  i.password
end

node(:errors, unless: lambda{ |i| i.valid? }) do |i|
  i.errors.messages
end
