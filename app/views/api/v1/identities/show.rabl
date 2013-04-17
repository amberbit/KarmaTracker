object @identity => :identity
attributes :id, :name, :api_key
attributes :user_id, :source_id, :last_projects_refresh_at, if: @current_admin.present?

node(:service) {|identity| identity.service_name }

attributes :username, :password, if: lambda{ |i|
  i.is_a?(GitHubIdentity) && !i.persisted? && !i.valid? && (i.username.present? || i.password.present?)
}

attributes :email, :password, if: lambda{ |i|
  i.is_a?(PivotalTrackerIdentity) && !i.persisted? && !i.valid? && (i.email.present? || i.password.present?)
}

node(:errors, unless: lambda{ |i| i.persisted? || i.valid? }) do |i|
  i.errors.messages
end
