object false

child(@identities.select{|i| i.type == "PivotalTrackerIdentity"} => 'pivotal_tracker') do
  extends 'api/v1/identities/show'
end

child(@identities.select{|i| i.type == "GitHubIdentity"} => 'git_hub') do
  extends 'api/v1/identities/show'
end
