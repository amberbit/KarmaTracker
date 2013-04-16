module Api
  module V1

    class UsersController < ApplicationController
      respond_to :json
      before_filter :restrict_access
      before_filter :set_user

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
        render 'show'
      end

      ##
      # Edit user's email and password.
      #
      # PUT /api/v1/user
      #
      # params:
      #   token - KarmaTracker API token
      #   user[email] - user's new email (optional)
      #   user[password] - user's new password (optional)
      #
      # = Examples
      #
      #   resp = conn.put("/api/v1/user",
      #                   "token" => "4e9a06bff7603236d477f7bfacc2def5",
      #                   "user" => {"email" => "new@sample.com", "password" => "new password"})
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #
      #   => "{"user":{"id":1,"email":"new@sample.com","token":"4e9a06bff7603236d477f7bfacc2def5"}}"
      #
      #   resp = conn.put("/api/v1/user",
      #                   "token" => "4e9a06bff7603236d477f7bfacc2def5",
      #                   "user" => {"email" => "user@example.com", "password" => "new"})
      #
      #   resp.status
      #   => 422
      #
      #   resp.body
      #   => "{"user":{"id":1,"email":"user@example.com","token":"4e9a06bff7603236d477f7bfacc2def5",
      #                "errors": {"email":["has already been taken"],"password":["is too short (minimum is 8 characters)"]}}}"
      #
      def update
        @user = UsersFactory.new(@user, params[:user]).update

        if @user.save
          render 'show'
        else
          render 'show', status: 422
        end
      end

      ##
      # Destroy current user based on provided API token. Success only if config option 'allow_destroy_user' set to true.
      #
      # DELETE /api/v1/user
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.delete("/api/v1/user",
      #                   "token" => "4e9a06bff7603236d477f7bfacc2def5")
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => "{"user":{"id":1,"email":"new@sample.com","token":"4e9a06bff7603236d477f7bfacc2def5"}}"
      #
      #   resp = conn.delete("/api/v1/user",
      #                   "token" => "4e9a06bff7603236d477f7bfacc2def5")
      #   resp.status
      #   => 403
      #
      #   resp.body
      #   => "{"message":"Forbidden"}"
      #
      def destroy
        if AppConfig.allow_destroy_user
          @user.destroy
          render 'show'
        else
          render json: {message: 'Forbidden'}, status: 403
        end
      end

      private

      def set_user
        @user = @current_user
      end

    end
  end
end
