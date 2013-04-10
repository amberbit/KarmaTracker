collection @identities
attributes :id, :name, :api_key
node(:service) {|identity| identity.service_name }
