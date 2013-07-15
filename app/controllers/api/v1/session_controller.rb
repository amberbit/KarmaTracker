module Api
  module V1
    class SessionController < ApplicationController
      respond_to :json

      ##
      # Authenticates user and returns user object with API Token.
      #
      # POST /api/v1/session
      #
      # params:
      #   session[email] - user email
      #   session[password] - user password
      #
      # = Examples
      #
      #   resp = conn.post("/api/v1/session",
      #                    "session[email]" => 'a@b.com',
      #                    "session[password]" => "asdf1234")
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"user":{"id":1,"email":"a@b.com","token":"644cef349e7b80d3e7151c980dccf2ec"}}
      #
      #   resp = conn.post("/api/v1/session",
      #                    "session[email]" => 'a@b.com',
      #                    "session[password]" => "invalid")
      #   resp.status
      #   => 401
      #
      #   resp.body
      #   => {"message": "Invalid email or password"}
      #
      def create
        if @user = User.authenticate(params[:session])
          if @user.confirmation_token.nil?
            @api_key = @user.api_key
            render 'api/v1/users/_show'
          else
	    UserMailer.confirmation_email(@user, request.host).deliver
            render json: {message: 'User email address is not confirmed, please check your inbox or spam folder.'}, status: 401
          end
        else
          render json: {message: 'Invalid email or password'}, status: 401
        end
      end

    end
  end
end
