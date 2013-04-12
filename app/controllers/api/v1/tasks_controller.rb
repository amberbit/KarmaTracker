module Api
  module V1

    class TasksController < ApplicationController
      respond_to :json
      before_filter :restrict_access
      before_filter :set_task

      ##
      # Start given task and returns it.
      #
      # GET /api/v1/tasks/:id/start
      #
      # params:
      #   id - ID of task to start
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/tasks/1/start",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => "{"task":{"id":1,"running":true}}"
      #
      def start
        @task.start(@current_user.id) unless @current_user.running_task.present?
        render 'show'
      end

      ##
      # Stop given task and returns it.
      #
      # GET /api/v1/tasks/:id/stop
      #
      # params:
      #   id - ID of task to stop
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/tasks/1/stop",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => "{"task":{"id":1,"running":false}}"
      #
      def stop
        @task.stop(@current_user)
        render 'show'
      end

      private

      def set_task
        @task = Task.find params[:id]
      end

    end
  end
end
