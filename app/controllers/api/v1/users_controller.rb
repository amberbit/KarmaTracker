module Api
  module V1

    class UsersController < ApplicationController
      respond_to :json
      before_filter :restrict_access, except: [:authenticate]

      def authenticate
        if user = User.authenticate(params[:email], params[:password])
          @api_key = user.api_key
          render 'authenticate'
        else
          head :unauthorized
        end
      end

      def me
        @user = @api_key.user
        render 'show'
      end

    end
  end
end
