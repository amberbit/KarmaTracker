module Api
  module V1
    class ProjectsController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      ##
      # Returns array of projects user participates in
      #
      # GET /api/v1/projects
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => [{"project": {"id":1, "name": "Sample project", "source_name": "Pivotal Tracker", "source_identifier": "123456"}},
      #       {"project": {"id":3, "name": "Some random name "source_name": "GitHub", "source_identifier": "42"}}]
      #
      def index
        @projects = @api_key.user.projects
        render 'index'
      end

      ##
      # Returns single project
      #
      # GET /api/v1/projects/:id
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects/1")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"project": {"id":1, "name": "Sample project", "source_name": "Pivotal Tracker", "source_identifier": "123456"}}
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
        @project = Project.find(params[:id])
        if @api_key.user.projects.include? @project
          render 'show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Triggers projects list refresh for all identities of the user.
      # Refreshing runs in background, so the response is sent without waiting for it to finish.
      #
      # GET /api/v1/refresh
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects/refresh")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"message": "Projects list refresh started"}
      #
      def refresh
        ProjectsFetcher.new.background.fetch_for_user(@api_key.user)
        render json: {message: 'Projects list refresh started'}, status: 200
      end

      ##
      # Triggers projects list refresh for a single identities.
      # Refreshing runs in background, so the response is sent without waiting for it to finish.
      #
      # GET /api/v1/refresh_for_identity/:id
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects/refresh_for_identity/1")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"message": "Projects list refresh started"}
      #
      #   resp = conn.get("/api/v1/projects/refresh_for_identity/123")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def refresh_for_identity
        identity = Identity.find_by_id(params[:id])
        if identity && identity.user.api_key == @api_key
          ProjectsFetcher.new.background.fetch_for_identity(identity)
          render json: {message: 'Projects list refresh started'}, status: 200
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

    end
  end
end
