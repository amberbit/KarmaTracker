TorqueBox.configure do
  web do
    context '/'
  end

  job ProjectsRefresher do
    description "Periodically refreshes projects list for each user identity"
    cron "0 0 * * * ?"
  end

end
