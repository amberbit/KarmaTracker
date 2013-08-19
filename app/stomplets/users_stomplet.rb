# users_stomplet.rb
require 'torquebox-stomp'

class UsersStomplet < TorqueBox::Stomp::JmsStomplet
  def initialize()
    super
    @destination = inject( '/users/:id' )
  end

  def on_message(stomp_message, session)
    username = session[:username]
    stomp_message.headers['sender'] = username
    stomp_message.headers['recipient'] = 'users'
    send_to( @destination, stomp_message )
  end
end
