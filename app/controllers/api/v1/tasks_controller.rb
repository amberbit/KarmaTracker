module Api
  module V1

    class TasksController < ApplicationController
      respond_to :json
      before_filter :restrict_access
      before_filter :set_task

      def start
        @task.start(@current_user.id) unless @current_user.running_task.present?
        render 'show'
      end

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
