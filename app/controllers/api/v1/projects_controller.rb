module Api
  module V1
    class ProjectsController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def index
        @projects = @api_key.user.projects
        render 'index'
      end

      def show
        @project = Project.find(params[:id])
        if @api_key.user.projects.include? @project
          render 'show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

    end
  end
end
