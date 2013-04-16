module Api
  module V1
    module Admin

      class IdentitiesController < AdminController
        before_filter :set_identity, only: [:show, :update, :destroy]
        respond_to :json

        ##
        # Returns list of all identities for all existing users.
        #
        # GET /api/v1/admin/identities
        #
        # params:
        #   token - KarmaTracker Admin API token
        #
        # = Examples
        #
        #   resp = conn.get("/api/v1/admin/identities", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
        #
        #   resp.status
        #   => 200
        #
        #   resp.body
        #   => "{"pivotal_tracker":[{"id":15,"name":"PT identity","api_key":"3ea75a6c7a88edaa8d1534ec5612c87c", "user_id":1,
        #                "source_id":"123456","last_projects_refresh_at":"2013-04-15T10:06:08Z","service":"Pivotal Tracker"}],
        #        "git_hub":[]}"
        #
        def index
          @identities = Identity.all
          render 'api/v1/identities/index'
        end

        ##
        # Returns single identity.
        #
        # GET /api/v1/admin/identities/:id
        #
        # params:
        #   token - KarmaTracker Admin API token
        #   id - ID of identity to fetch
        #
        # = Examples
        #
        #   resp = conn.get("/api/v1/admin/identities/15", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
        #
        #   resp.status
        #   => 200
        #
        #   resp.body
        #   => "{"identity":{"id":15,"name":"PT identity","api_key":"3ea75a6c7a88edaa8d1534ec5612c87c","user_id":1,
        #                    "source_id":"526127","last_projects_refresh_at":"2013-04-15T10:06:08Z","service":"Pivotal Tracker"}}"
        #
        #   resp = conn.get("/api/v1/admin/identities/16", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
        #
        #   resp.status
        #   => 404
        #
        #   resp.body
        #   => {"message": "Resource not found"}
        #
        def show
          render 'api/v1/identities/show'
        end

        ##
        # Creates new Pivotal Tracker identity.
        #
        # POST /api/v1/admin/identities/pivotal_tracker
        #
        # params:
        #   token - KarmaTracker Admin API token
        #   identity[user_id] - ID of KarmaTracker user assigned to identity
        #   identity[name] - identity name
        #   identity[api_key] - Pivotal Tracker API token
        #   identity[email] - email assigned to PT account
        #   identity[password] - password assigned to PT account
        # Either api_key or email and password need to be provided.
        #
        # = Examples
        #
        #   resp = conn.post("/api/v1/admin/identities/pivotal_tracker",
        #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
        #                    "identity[user_id]" => 1,
        #                    "identity[name]" => "New identity",
        #                    "identity[api_key]" => "3ea75a6c7a88edaa8d1534ec5612c87c")
        #
        #   resp.status
        #   => 200
        #
        #   resp.body
        #   => "{"identity":{"id":19,"name":"New identity","api_key":"3ea75a6c7a88edaa8d1534ec5612c87c","user_id":1,
        #                    "source_id":"526127","last_projects_refresh_at":null,"service":"Pivotal Tracker"}}"
        #
        #   resp = conn.post("/api/v1/admin/identities/pivotal_tracker",
        #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
        #                    "identity[user_id]" => 1,
        #                    "identity[name]" => "New identity 2",
        #                    "identity[api_key]" => "wrong token")
        #
        #   resp.status
        #   => 422
        #
        #   resp.body
        #   => "{"identity":{"id":null,"name":"New identity 2","api_key":"wrong token","user_id":1,"source_id":null,
        #                    "last_projects_refresh_at":null,"service":"Pivotal Tracker","errors":{"api_key":["provided API token is invalid"]}}}"
        #
        #   resp = conn.post("/api/v1/admin/identities/pivotal_tracker",
        #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
        #                    "identity[user_id]" => 2,
        #                    "identity[name]" => "New identity 3",
        #                    "identity[api_key]" => "3ea75a6c7a88edaa8d1534ec5612c87c")
        #
        #   resp.status
        #   => 422
        #
        #   resp.body
        #   => "{"identity":{"id":null,"name":"New identity 3","api_key":"3ea75a6c7a88edaa8d1534ec5612c87c","user_id":2,"source_id":"526127",
        #                    "last_projects_refresh_at":null,"service":"Pivotal Tracker","errors":{"user":["can't be blank"]}}}"
        #
        def pivotal_tracker
          @identity = IdentitiesFactory.new(PivotalTrackerIdentity.new, params[:identity]).create_identity
          if @identity.save
            render 'api/v1/identities/show'
          else
            render 'api/v1/identities/show', status: 422
          end
        end

        ##
        # Edit existing KT-PT/GH identity. Only name could be currently changed.
        #
        # PUT /api/v1/admin/identities/:id
        #
        # params:
        #   token - KarmaTracker Admin API token
        #   id - ID of identity to destroy
        #   identity[name] - new identity name.
        #
        # = Examples
        #
        #   resp = conn.put("/api/v1/admin/identities/21",
        #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
        #                    "identity[name]" => "New name")
        #
        #   resp.status
        #   => 200
        #
        #   resp.body
        #   => "{"identity":{"id":21,"name":"New name","api_key":"3ea75a6c7a88edaa8d1534ec5612c87c","user_id":1,"source_id":"526127",
        #                    "last_projects_refresh_at":null,"service":"Pivotal Tracker"}}"
        #
        #   resp = conn.put("/api/v1/admin/identities/21",
        #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
        #                    "identity[api_key]" => "New key")
        #
        #   resp.status
        #   => 200
        #
        #   resp.body
        #   => "{"identity":{"id":21,"name":"New name","api_key":"3ea75a6c7a88edaa8d1534ec5612c87c","user_id":1,"source_id":"526127",
        #                    "last_projects_refresh_at":null,"service":"Pivotal Tracker"}}"
        #
        def update
          @identity = IdentitiesFactory.new(@identity, params[:identity]).update_identity

          if @identity.save
            render 'api/v1/identities/show'
          else
            render 'api/v1/identities/show', status: 422
          end
        end

        ##
        # Delete any identity
        #
        # DELETE /api/v1/identities/:id
        #
        # params:
        #   token - KarmaTracker Admin API token
        #   id - ID of identity to destroy
        #
        # = Examples
        #
        #   resp = conn.delete("/api/v1/admin/identities/20", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
        #
        #   resp.status
        #   => 200
        #
        #   resp.body
        #   => "{"identity":{"id":20,"name":"PT identity","api_key":"3ea75a6c7a88edaa8d1534ec5612c87c","user_id":1,"source_id":"526127",
        #                    "last_projects_refresh_at":null,"service":"Pivotal Tracker"}}"
        #
        #   resp = conn.delete("/api/v1/admin/identities/21", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
        #
        #   resp.status
        #   => 404
        #
        #   resp.body
        #   => {"message": "Resource not found"}
        #
        def destroy
          @identity.destroy
          render 'api/v1/identities/show'
        end

        private

        def set_identity
          @identity = Identity.find params[:id]
        end
      end

    end
  end
end
