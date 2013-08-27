# projects_stomplet.rb
require 'torquebox-stomp'

class ProjectsStomplet < TorqueBox::Stomp::JmsStomplet
  def initialize()
    super
    @destination = inject( '/projects/subscribe' )
  end

  def on_message(stomp_message, session)
    user_id = session[:user_id]
    stomp_message.headers['user_id'] = user_id
    send_to( @destination, stomp_message )
  end

  def on_subscribe(subscriber)
    logger.debug "==================================="
    logger.debug "subscribed"
    logger.debug "==================================="
    user_id = subscriber.session[:user_id]
    subscribe_to( subscriber,
                 @destination,
                 "user_id='#{user_id}'" )
  end
end
