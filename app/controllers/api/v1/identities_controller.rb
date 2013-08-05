module Api
  module V1
    class IdentitiesController < ApplicationController
      before_filter :restrict_access
      respond_to :json

      ##
      # Returns list of user's identities, optionally filtered by service
      #
      # GET /api/v1/identities
      #
      # params:
      #   token - KarmaTracker API token
      #   optional:
      #     service - name of the service for which identities should be returned;
      #               both CamelCase and snake_case notations are supported.
      #               Valid values:
      #                 - PivotalTracker
      #                 - pivotal_tracker
      #                 - GitHub
      #                 - git_hub
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/identities", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {[{"pivotal_tracker": {"id": 1, "api_key": "123456", "service": "Pivotal Tracker"}},
      #       {"git_hub": {"id": 3, "api_key": "42", "service": "GitHub"}}]}
      #
      #   resp = conn.get("/api/v1/identities",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                   "service" => "pivotal_tracker")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {[{"pivotal_tracker":{"id":1, "api_key":"123456","service":"Pivotal Tracker"}}]}
      #
      def index
        @identities = if params[:service]
          @api_key.user.identities.by_service(params[:service])
        else
          @api_key.user.identities
        end
        render 'index'
      end

      ##
      # Returns single identity
      #
      # GET /api/v1/identities/:id
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/identities/1", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"pivotal_tracker": {"id": 1, "api_key": "123456", "service": "Pivotal Tracker"}}
      #
      #
      #   resp = conn.get("/api/v1/projects/7", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def show
        @identity = Identity.find_by_id(params[:id])
        if @identity && @identity.user.api_key == @api_key
          render '_show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # creates new Pivotal Tracker identity
      #
      # POST /api/v1/identities/pivotal_tracker
      #
      # params:
      #   token - KarmaTracker API token
      #   identity[api_key] - Pivotal Tracker API token
      #   identity[email] - email assigned to PT account
      #   identity[password] - password assigned to PT account
      # Either api_key or email and password need to be provided.
      #
      # = Examples
      #
      #   resp = conn.post("/api/v1/identities/pivotal_tracker",
      #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                    "identity[api_key]" => "sdgs24386tr8732gfsiur32")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"pivotal_tracker": {"id": 8, "api_key": "sdasdf32rfefs32", "service": "Pivotal Tracker"}}
      #
      #   resp = conn.post("/api/v1/identities/pivotal_tracker",
      #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                    "identity[api_key]" => "wrong token")
      #
      #   resp.status
      #   => 422
      #
      #   resp.body
      #   => {"pivotal_tracker": {"api_key": "wrong token", "errors": { "api_key": ["Is invalid"] }}}
      #
      #   resp = conn.post("/api/v1/identities/pivotal_tracker",
      #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                    "identity[email]" => "mail@example.com"
      #                    "identity[password]" => "wrong_password")
      #
      #   resp.status
      #   => 422
      #
      #   resp.body
      #   => {"pivotal_tracker": {"email": "mail@example.com", "password": "wrong_password",
      #                           "errors": { "password": ["does not match email"] }}}
      #
      def pivotal_tracker
        options = (params[:identity] || {}).merge({user_id: @current_user.id})
        @identity = IdentitiesFactory.new(PivotalTrackerIdentity.new, options).create
        if @identity.save
          render '_show'
        else
          render '_show', status: 422
        end
      end

      ##
      # creates new GitHub identity
      #
      # POST /api/v1/identities/git_hub
      #
      # params:
      #   token - KarmaTracker API token
      #   identity[api_key] - GitHub API token
      #   identity[username] - username assigned to GH account
      #   identity[password] - password assigned to GH account
      #
      # = Examples
      #
      #   resp = conn.post("/api/v1/identities/git_hub",
      #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                    "identity[username]" => "R2D2"
      #                    "identity[password]" => "fdsjfsho7h23orfesk")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"git_hub": {"id": 9, "api_key": "sdasdf32rfefs32", "service": "GitHub"}}
      #
      #   resp = conn.post("/api/v1/identities/git_hub",
      #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                    "identity[username]" => "R2D2"
      #                    "identity[api_key]" => "osdf659234sdffd3sjfsh234o7h23orfe3sk")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"git_hub": {"id": 10, "api_key": "osdf659234sdffd3sjfsh234o7h23orfe3sk", "service": "GitHub"}}
      #
      #   resp = conn.post("/api/v1/identities/pivotal_tracker",
      #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                    "identity[username]" => "R2D2"
      #                    "identity[password]" => "wrongpassword")
      #
      #   resp.status
      #   => 422
      #
      #   resp.body
      #   => {"git_hub": {"api_key": "wrong token", "errors": { "api_key": ["Is invalid"] }}}
      #
      def git_hub
        options = (params[:identity] || {}).merge({user_id: @current_user.id})
        @identity = IdentitiesFactory.new(GitHubIdentity.new, options).create
        if @identity.save
          render '_show'
        else
          render '_show', status: 422
        end
      end

      ##
      # Deletes identity
      #
      # DELETE /api/v1/identities/:id
      #
      # params:
      #   token - KarmaTracker API token
      #
      #
      # = Examples
      #
      #   resp = conn.delete("/api/v1/identities/1", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"pivotal_tracker": {"id": 1, "api_key": "123456", "service": "Pivotal Tracker"}}
      #
      #   resp = conn.delete("/api/v1/identities/123", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def destroy
        @identity = Identity.find_by_id(params[:id])
        if @identity && @identity.user.api_key == @api_key
          @identity.delete
          render '_show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

    end
  end
end
