module Api
  module V1

    class UsersController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def user
        @user = @api_key.user
        render 'show'
      end

    end
  end
end
