module Api
  module V1

    class UsersController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      ##
      # Returns KarmaTracker user based on provided API token
      #
      # GET /api/v1/user
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/user",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"user":{"id":1,"email":"a@b.com","token":"dcbb7b36acd4438d07abafb8e28605a4"}}
      #
      def user
        @user = @api_key.user
        render 'show'
      end

    end
  end
end
