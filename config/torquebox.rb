TorqueBox.configure do

  topic '/queues/public'

  web do
    context '/'
  end

  stomp do
    host 'localhost'
  end

  stomplet ProjectsStomplet do
    route '/queues/public'
  end

end
