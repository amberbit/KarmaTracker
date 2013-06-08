module Api
  module V1
    class TasksController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      ##
      # Returns single task
      #
      # GET /api/v1/tasks/:id
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/tasks/1", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"task":{"id":1,"project_id":63,"source_name":"GitHub","source_identifier":"9216238/9","current_state":"open","story_type":"issue","current_task":true,"name":"Sample name","running":false}}
      #
      #
      #   resp = conn.get("/api/v1/tasks/7", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def show
        @task = Task.find(params[:id])
        if @api_key.user.projects.include? @task.project
          render '_show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Returns current running task if any
      #
      # GET /api/v1/tasks/running
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/tasks/running", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"task":{"id":1,"project_id":63,"source_name":"GitHub","source_identifier":"9216238/9","current_state":"open","story_type":"issue","current_task":true,"name":"Sample name","running":true}}
      #
      #
      #   resp = conn.get("/api/v1/tasks/running", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #

      def running
        scope = @current_user.time_log_entries
        running_task = Task.find_by_id(scope.find_by_running!("true").task_id)
        @task = running_task
        if running_task
          render '_show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end

      end


    end
  end
end
