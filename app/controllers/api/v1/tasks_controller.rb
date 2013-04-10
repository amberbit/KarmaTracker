module Api
  module V1

    class TasksController < ApplicationController
      respond_to :json
      before_filter :restrict_access
      before_filter :set_task

      def start
        if @current_user.running_task.present?
          if @current_user.running_task == @task
            render json: {status: 200, message: 'Task already running'}
          else
            render json: {status: 200, message: 'Another task running'}
          end
        else
          @task.start @current_user.id
          render json: {status: 200, message: 'Task started'}
        end
      end

      def stop
        if @task.running? @current_user.id
          @task.stop @current_user
          render json: {status: 200, message: 'Task stopped'}
        else
          render json: {status: 200, message: 'Task not running'}
        end
      end

      private

      def set_task
        @task = Task.find params[:id]
      end

    end
  end
end
