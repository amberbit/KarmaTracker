module Api
  module V1
    module Admin

      class UsersController < AdminController
        before_filter :set_user, only: [:show, :update, :destroy]
        respond_to :json

        ##
        # Returns list of all users in the KarmaTracker DB. Adds flag whether user is an admin.
        #
        # GET /api/v1/admin/users
        #
        # params:
        #   token - KarmaTracker Admin API token
        #
        # = Examples
        #
        #   resp = conn.get("/api/v1/admin/users",
        #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4")
        #   resp.status
        #   => 200
        #
        #   resp.body
        #  => "{[{"user": {"id":1,"email":"user@example.com","token":"dcbb7b36acd4438d07abafb8e28605a4","admin":true}},
        #         {"user": {"id":113,"email":"ja@example.com","token":"75bff89de188de4cc1c13a2df1d6f160","admin":false}}]}"
        #
        def index
          @users = User.all
          render 'index'
        end

        ##
        # Returns one of the users.
        #
        # GET /api/v1/admin/users/:id
        #
        # params:
        #   token - KarmaTracker Admin API token
        #   id - ID of user to fetch
        #
        # = Examples
        #
        #   resp = conn.get("/api/v1/admin/users/1",
        #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4")
        #   resp.status
        #   => 200
        #
        #   resp.body
        #   => "{"user":{"id":1,"email":"user@example.com","token":"dcbb7b36acd4438d07abafb8e28605a4","admin":true}}"
        #
        def show
          render 'api/v1/users/show'
        end

        ##
        # Creates new regular user and returns it with API access token.
        #
        # POST /api/v1/admin/users
        #
        # params:
        #   token - KarmaTracker Admin API token
        #   user[email] - new user's email
        #   user[password] - new user's password
        #
        # = Examples
        #
        #   resp = conn.post("/api/v1/admin/users",
        #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4",
        #                   "user" => {"email" => "sample@sample.com", "password" => "1234567890"})
        #
        #   resp.status
        #   => 200
        #
        #   resp.body
        #   => "{"user":{"id":114,"email":"sample@sample.com","token":"ae006c814f2a5fa3bf0d543bb26bc141","admin":false}}"
        #
        #   resp = conn.post("/api/v1/admin/users",
        #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4",
        #                   "user" => {"email" => "sample@sample.com", "password" => "1234"})
        #
        #   resp.status
        #   => 422
        #
        #   resp.body
        #   => "{"user":{"id":null,"email":"sample@sample.com","errors":
        #                    {"email":["has already been taken"],
        #                    "password":["is too short (minimum is 8 characters)"]}}}"
        #
        def create
          @user = User.new params[:user]

          if @user.save
            render 'api/v1/users/show'
          else
            render 'api/v1/users/show', status: 422
          end
        end

        ##
        # Edit existing user by admin. All default validations still applies.
        #
        # PUT /api/v1/admin/users/:id
        #
        # params:
        #   token - KarmaTracker Admin API token
        #   id - ID of the user to update
        #   user[email] - user's new email
        #   user[password] - user's new password
        #
        # = Examples
        #
        #   resp = conn.put("/api/v1/admin/users/114",
        #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4",
        #                   "user" => {"email" => "new@sample.com"})
        #
        #   resp.status
        #   => 200
        #
        #   resp.body
        #   => "{"user":{"id":114,"email":"new@sample.com","token":"ae006c814f2a5fa3bf0d543bb26bc141","admin":false}}"
        #
        #   resp = conn.put("/api/v1/admin/users/115",
        #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4",
        #                   "user" => {"email" => "new@sample.com"})
        #
        #   resp.status
        #   => 404
        #
        #   resp.body
        #   => "{"message":"Resource not found"}"
        #
        def update
          if @user.update_attributes params[:user]
            render 'api/v1/users/show'
          else
            render 'api/v1/users/show', status: 422
          end
        end

        ##
        # Completely remove user and all his resources from DB.
        #
        # DELETE /api/v1/admin/users/:id
        #
        # params:
        #   token - KarmaTracker Admin API token
        #   id - ID of the user to destroy
        #
        # = Examples
        #
        #   resp = conn.delete("/api/v1/admin/users/114",
        #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4")
        #
        #   resp.status
        #   => 200
        #
        #   resp.body
        #   => "{"user":{"id":114,"email":"new@sample.com","token":"ae006c814f2a5fa3bf0d543bb26bc141","admin":false}}"
        #
        def destroy
          @user.destroy
          render 'api/v1/users/show'
        end

        private

        def set_user
          @user = User.find(params[:id])
        end

      end

    end
  end
end
