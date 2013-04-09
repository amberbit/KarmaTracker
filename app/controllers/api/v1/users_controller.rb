module Api
  module V1
    class UsersController < ApplicationController
      respond_to :json
      before_filter :restrict_access, except: [:authenticate]

      def authenticate
        respond_with (user = User.authenticate(params[:email], params[:password])) ? user.api_key : {}
      end

      def me
        respond_with @api_key.user
      end

    end
  end
end
