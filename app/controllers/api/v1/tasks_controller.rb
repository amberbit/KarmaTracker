module Api
  module V1

    class TasksController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      private

      def set_task
        @task = Task.find params[:id]
      end

    end
  end
end
