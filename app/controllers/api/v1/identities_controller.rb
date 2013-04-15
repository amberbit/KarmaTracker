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
      #   resp = conn.get("/api/v1/identities")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"pivotal_tracker": [{"pivotal_tracker": {"id": 1, "name": "John Doe", "api_key": "123456", "service": "Pivotal Tracker"}}],
      #       "git_hub": [{"git_hub": {"id": 3, "name": "John Doe's GH identity", "api_key": "42", "service": "GitHub"}}]}
      #
      #   resp = conn.get("/api/v1/identities",
      #                    "service" => "pivotal_tracker")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"pivotal_tracker":[{"pivotal_tracker":{"id":1,"name":"John Doe","api_key":"123456","service":"Pivotal Tracker"}}],
      #       "git_hub":[]}
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
      # = Examples
      #
      #   resp = conn.get("/api/v1/identities/1")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"identity": {"id": 1, "name": "John Doe", "api_key": "123456", "service": "Pivotal Tracker"}}
      #
      #
      #   resp = conn.get("/api/v1/projects/7")
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
          render 'show'
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
      #   identity[name] - identity name
      #   identity[api_key] - Pivotal Tracker API token
      #   identity[email] - email assigned to PT account
      #   identity[password] - password assigned to PT account
      # Either api_key or email and password need to be provided.
      #
      # = Examples
      #
      #   resp = conn.post("/api/v1/identities/pivotal_tracker"
      #                    "identity[name]" => "New identity",
      #                    "identity[api_key]" => "sdgs24386tr8732gfsiur32")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"identity": {"id": 8, "name": "New identity", "api_key": "sdasdf32rfefs32", "service": "Pivotal Tracker"}}
      #
      #   resp = conn.post("/api/v1/identities/pivotal_tracker"
      #                    "identity[name]" => "New identity 2",
      #                    "identity[api_key]" => "wrong token")
      #
      #   resp.status
      #   => 422
      #
      #   resp.body
      #   => {"identity": {"name": "New identity 2", "api_key": "wrong token", "errors": { "api_key": ["Is invalid"] }}}
      #
      #   resp = conn.post("/api/v1/identities/pivotal_tracker"
      #                    "identity[name]" => "New identity 3",
      #                    "identity[email]" => "mail@example.com"
      #                    "identity[password]" => "wrong_password")
      #
      #   resp.status
      #   => 422
      #
      #   resp.body
      #   => {"identity": {"name": "New identity 3", "email": "mail@example.com", "password": "wrong_password",  "errors": { "password": ["does not match email"] }}}
      #
      def pivotal_tracker
        options = (params[:identity] || {}).merge({user_id: @current_user.id})
        @identity = IdentitiesFactory.new(PivotalTrackerIdentity, options).create_identity
        if @identity.save
          render 'show'
        else
          render 'show', status: 422
        end
      end

      ##
      # Deletes identity
      #
      # DELETE /api/v1/identities/:id
      #
      # = Examples
      #
      #   resp = conn.delete("/api/v1/identities/1")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"identity": {"id": 1, "name": "John Doe", "api_key": "123456", "service": "Pivotal Tracker"}}
      #
      #   resp = conn.delete("/api/v1/identities/123")
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
          render 'api/v1/identities/show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

    end
  end
end
