object false

child(@identities.select{|i| i.type == "PivotalTrackerIdentity"} => 'pivotal_tracker') do
  extends 'api/v1/identities/show', locals: {header: false}
end

child(@identities.select{|i| i.type == "GitHubIdentity"} => 'github') do
  extends 'api/v1/identities/show', locals: {header: false}
end
