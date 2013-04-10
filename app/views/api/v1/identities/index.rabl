collection @identities, :root => false, :object_root => :identity
attributes :id , :name, :api_key
node(:service) {|identity| identity.service_name }
