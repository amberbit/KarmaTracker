TorqueBox.configure do
  web do
    context '/'
  end

  job ProjectsRefresher do
    description "Periodically refreshes projects list for each user identity"
    cron "*/5 * * * * ?"
  end

end
