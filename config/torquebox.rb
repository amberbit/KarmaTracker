TorqueBox.configure do
  web do
    context '/'
  end

  job ProjectsRefresher do
    description "Periodically refreshes projects list for each user integration"
    cron "0 0 * * * ?"
  end

end
