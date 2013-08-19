TorqueBox.configure do
  web do
    context '/'
  end

  job ProjectsRefresher do
    description "Periodically refreshes projects list for each user identity"
    cron "0 0 * * * ?"
  end

  stop do
    stomplets do
      users do
        class 'UsersStomplet'
        route 'users/:id'
      end

      projects do
        class 'ProjectsStomplet'
        route 'projects/:id/subscribe'
      end
    end
  end
end
