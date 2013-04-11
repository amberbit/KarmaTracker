module Api
  module V1
    class SessionsController < ApplicationController
      respond_to :json

      def create
        if @user = User.authenticate(params[:session])
          @api_key = @user.api_key
          render 'api/v1/users/show'
        else
          render json: {message: 'Invalid email or password'}, status: 401
        end
      end

    end
  end
end
