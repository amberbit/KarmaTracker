class ErrorsController < ActionController::API

  def not_found
    render json: {message: 'Resource not found'}, status: 404
  end

  def exception
    render json: {message: 'Internal Server Error'}, status: 500
  end

end
