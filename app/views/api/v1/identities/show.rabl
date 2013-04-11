object @identity => :identity
attributes :id, :name, :api_key
node(:service) {|identity| identity.service_name }

attributes :email, :password, if: lambda{ |i|
  !i.persisted? && !i.valid? && (i.email.present? || i.password.present?)
}

node(:errors, unless: lambda{ |i| i.persisted? || i.valid? }) do |i|
  i.errors.messages
end
