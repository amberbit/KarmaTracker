class ApplicationController < ActionController::API

  private

  def restrict_access
    head :unauthorized unless restrict_access_by_params || restrict_access_by_header
  end

  def restrict_access_by_header
    authenticate_or_request_with_http_token do |token, options|
      @api_key = ApiKey.find_by_access_token(access_token: token)
      @api_key.present?
    end
  end

  def restrict_access_by_params
    @api_key = ApiKey.find_by_access_token(params[:token])
  end

end
