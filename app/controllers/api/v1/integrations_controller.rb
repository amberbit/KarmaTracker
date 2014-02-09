module Api
  module V1
    class IntegrationsController < ApplicationController
      before_filter :restrict_access
      respond_to :json

      ##
      # Returns list of user's integrations, optionally filtered by service
      #
      # GET /api/v1/integrations
      #
      # params:
      #   token - KarmaTracker API token
      #   optional:
      #     service - name of the service for which integrations should be returned;
      #               both CamelCase and snake_case notations are supported.
      #               Valid values:
      #                 - PivotalTracker
      #                 - pivotal_tracker
      #                 - GitHub
      #                 - git_hub
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/integrations", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {[{"pivotal_tracker": {"id": 1, "api_key": "123456", "service": "Pivotal Tracker"}},
      #       {"git_hub": {"id": 3, "api_key": "42", "service": "GitHub"}}]}
      #
      #   resp = conn.get("/api/v1/integrations",
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
        if @api_key && @api_key.user
          @integrations = if params[:type]
                          @api_key.user.integrations.by_service(params[:type])
                        else
                          @api_key.user.integrations
                        end
          render 'index'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Returns single integration
      #
      # GET /api/v1/integrations/:id
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/integrations/1", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
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
        @integration = Integration.find_by_id(params[:id])
        if @integration && @integration.user.api_key == @api_key
          render '_show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # creates new Pivotal Tracker or Git Hub integration
      #
      # POST /api/v1/integrations
      #
      # params:
      #   token - KarmaTracker API token
      #   integration[api_key] - Pivotal Tracker API token
      #   integration[email] - email assigned to PT account
      #   integration[password] - password assigned to PT account
      # Either api_key or email and password need to be provided.
      #   integration[type] - integration type: 'git_hub'/'GitHub' or 'pivotal_tracker'/'PivotalTracker'
      #
      # = Examples
      #
      #   resp = conn.post("/api/v1/integrations/pivotal_tracker",
      #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                    "integration[api_key]" => "sdgs24386tr8732gfsiur32",
      #                    "integration[type] => 'pivotal_tracker')
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"pivotal_tracker": {"id": 8, "api_key": "sdasdf32rfefs32", "service": "Pivotal Tracker"}}
      #
      #   resp = conn.post("/api/v1/integrations/pivotal_tracker",
      #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                    "integration[api_key]" => "wrong token",
      #                    "integration[type] => 'pivotal_tracker')
      #
      #   resp.status
      #   => 422
      #
      #   resp.body
      #   => {"pivotal_tracker": {"api_key": "wrong token", "errors": { "api_key": ["Is invalid"] }}}
      #
      #   resp = conn.post("/api/v1/integrations/pivotal_tracker",
      #                    "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                    "integration[email]" => "mail@example.com"
      #                    "integration[password]" => "wrong_password",
      #                    "integration[type] => 'pivotal_tracker')
      #
      #   resp.status
      #   => 422
      #
      #   resp.body
      #   => {"pivotal_tracker": {"email": "mail@example.com", "password": "wrong_password",
      #                           "errors": { "password": ["does not match email"] }}}
      def create
        options = (params[:integration].reject{ |key, value| value.empty?} || {}).merge({user_id: @current_user.id})
        @integration = IntegrationsFactory.new(IntegrationsFactory.construct_integration(options['type']), options).create
        if @integration.save
          render '_show'
        else
          render '_show', status: 422
        end
      end


      ##
      # Deletes integration
      #
      # DELETE /api/v1/integrations/:id
      #
      # params:
      #   token - KarmaTracker API token
      #
      #
      # = Examples
      #
      #   resp = conn.delete("/api/v1/integrations/1", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"pivotal_tracker": {"id": 1, "api_key": "123456", "service": "Pivotal Tracker"}}
      #
      #   resp = conn.delete("/api/v1/integrations/123", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def destroy
        @integration = Integration.find_by_id(params[:id])
        if @integration && @integration.user.api_key == @api_key
          @integration.delete
          render '_show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

    end
  end
end
