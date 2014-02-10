module Api
  module V1

    class UsersController < ApplicationController
      respond_to :json
      before_filter :restrict_access, except: [:create, :confirm]

      ##
      # Returns KarmaTracker user based on provided API token.
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
      #   => {"user":{"id":1,"email":"a@b.com","refreshing":"tasks",
      #               "gravatar_url":"http://www.gravatar.com/avatar/b642b4217b3sds456sd7d5f4c4452",
      #                "token":"dcbb7b36acd4438d07abafb8e28605a4"}}
      #
      def show
        if @api_key && @api_key.user
          render '_show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Register new user. Do not require API token.
      # Password length validation based on AppConfig option 'users.password_min_chars' (default = 6)
      #
      # POST /api/v1/user
      #
      # params:
      #   user[email] - new user's email
      #   user[password] - new user's password
      #
      # = Examples
      #
      #   resp = conn.post("/api/v1/user",
      #                   "user" => {"email" => "new@example.com", "password" => "secret"})
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => "{"user":{"id":117,"email":"new@example.com",
      #                "gravatar_url":"http://www.gravatar.com/avatar/b642b4217b3sds456sd7d5f4c4452",
      #                "token":"5266cd376cf2a29fd810c62ed731ec3a"}}"
      #
      #   resp = conn.post("/api/v1/user",
      #                   "user" => {"email" => "new@example.com", "password" => "123"})
      #   resp.status
      #   => 422
      #
      #   resp.body
      #   => "{"user":{"id":null,"email":"new@example.com",
      #                "gravatar_url":"http://www.gravatar.com/avatar/b642b4217b3sds456sd7d5f4c4452",
      #                "errors":{"password":["is too short (minimum is 6 characters)"]}}}"
      #
      #   resp = conn.post("/api/v1/user",
      #                   "user" => {"email" => "new@example.com", "password" => "secret"})
      #   resp.status
      #   => 403
      #
      #   resp.body
      #   => "{"message":"Forbidden"}"
      #
      def create
        if AppConfig.users.allow_register
          @current_user = UsersFactory.new(User.new, params[:user]).create

          if @current_user.save
            UserMailer.confirmation_email(@current_user, request.host).deliver
            render '_show'
          else
            render '_show', status: 422
          end
        else
          render json: {message: 'Forbidden'}, status: 403
        end
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
      #   => "{"user":{"id":1,"email":"new@sample.com",
      #                "gravatar_url":"http://www.gravatar.com/avatar/b642b4217b3sds456sd7d5f4c4452",
      #                "token":"4e9a06bff7603236d477f7bfacc2def5"}}"
      #
      #   resp = conn.put("/api/v1/user",
      #                   "token" => "4e9a06bff7603236d477f7bfacc2def5",
      #                   "user" => {"email" => "user@example.com", "password" => "new"})
      #
      #   resp.status
      #   => 422
      #
      #   resp.body
      #   => "{"user":{"id":1,"email":"user@example.com",
      #                "gravatar_url":"http://www.gravatar.com/avatar/b642b4217b3sds456sd7d5f4c4452",
      #                "token":"4e9a06bff7603236d477f7bfacc2def5",
      #                "errors": {"email":["has already been taken"],"password":["is too short (minimum is 8 characters)"]}}}"
      #
      def update
        @current_user = UsersFactory.new(@current_user, params[:user]).update
        if @current_user.save
          render '_show'
        else
          render '_show', status: 422
        end
      end

      ##
      # Confirm user's email.
      #
      # GET /api/v1/user/confirm
      #
      # params:
      #   confirmation_token - user's confirmation token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/user/confirm",
      #                   "confirmation_token" => "4e9a06bff7603236d477f7bfacc2def5")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #
      #   => "{"user":{"id":1,"email":"new@sample.com",
      #                "gravatar_url":"http://www.gravatar.com/avatar/b642b4217b3sds456sd7d5f4c4452",
      #                "token":"7fcc0c838c7782405b7b20717e3c9ced"}}"
      #
      #
      #   resp = conn.get("/api/v1/user/confirm",
      #                   "confirmation_token" => "wrongconfirmationtoken")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #
      #   => "{"message":"Resource not found"}"
      #
      #

      def confirm
        @current_user = User.where(confirmation_token: params[:confirmation_token]).first
        @current_user.confirmation_token = nil if @current_user

        if @current_user && @current_user.save
          render '_show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Destroy current user based on provided API token. Success only if config option 'users.allow_destroy' set to true.
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
      #   => "{"user":{"id":1,"email":"new@sample.com",
      #                "gravatar_url":"http://www.gravatar.com/avatar/b642b4217b3sds456sd7d5f4c4452",
      #                "token":"4e9a06bff7603236d477f7bfacc2def5"}}"
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
        if AppConfig.users.allow_destroy
          @current_user.destroy
          render '_show'
        else
          render json: {message: 'Forbidden'}, status: 403
        end
      end

    end
  end
end
