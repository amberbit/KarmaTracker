class HomeController < ActionController::Base
  layout "application"

  def index
    render :action => :index
  end
end
