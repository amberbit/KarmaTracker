include ActionController::HttpAuthentication::Token::ControllerMethods
include ActionController::MimeResponds

class ApplicationController < ActionController::API

  private

  def restrict_access
    unless restrict_access_by_params(false) || restrict_access_by_header(false)
      render json: {message: 'Invalid API Token'}, status: 401
      return
    end

    @current_user = @api_key.user if @api_key
  end

  def restrict_access_by_header(admin=false)
    return true if @api_key

    authenticate_with_http_token do |token|
      @api_key = ApiKey.where(admin: admin).find_by_token(token)
    end
  end

  def restrict_access_by_params(admin=false)
    return true if @api_key

    @api_key = ApiKey.where(admin: admin).find_by_token(params[:token])
  end

end
