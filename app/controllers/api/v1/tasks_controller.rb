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
        if @task.present? && @api_key.user.projects.include?(@task.project)
          render '_show'
        else
          render json: {message: 'Task resource not found'}, status: 404
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
      #   => {"task":{"id":1,"project_id":63,"source_name":"GitHub","source_identifier":"9216238/9",
      #               "current_state":"open","story_type":"issue","current_task":true,"name":"Sample name",
      #               "running":true,"started_at":"2013-08-22T13:44:47Z"}}
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
        @log_entry  = @current_user.time_log_entries.where(running: true).first

        if @log_entry && @task = @log_entry.task
          render '_show'
        else
          render json: {message: '"Running" resource not found'}, status: 404
        end
      end

      ##
      # Returns a list of recent tasks for a given user
      #
      # GET /api/v1/tasks/recent
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/tasks/recent", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {[{"task":{"id":1191,"project_id":16,"source_name":"Pivotal Tracker","source_identifier":"47519693","current_state":"accepted","story_type":"feature",
      #                 "current_task":true,"name":"As a user, I want to get authorized with my username and password and retrieve API token for further API access.","running":false}},
      #        {"task":{"id":1192,"project_id":16,"source_name":"Pivotal Tracker","source_identifier":"47433253","current_state":"accepted","story_type":"chore",
      #                 "current_task":false,"name":"Research Pivotal API (v4) and Github Issues API (if there is)","running":false}}]}
      #
      #   resp = conn.get("/api/v1/tasks/recent", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def recent
        @tasks = Task.recent(@current_user)

        if @tasks[0].present?
          render template: "api/v1/projects/tasks"
        else
          render json: {message: '"Recent" resource not found'}, status: 404
        end
      end
    end
  end
end
