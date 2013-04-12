module Api
  module V1

    class TimeLogEntriesController < ApplicationController
      respond_to :json
      before_filter :restrict_access
      before_filter :set_entry, only: [:update]

      def create
        @time_log_entry = TimeLogEntriesFactory.new(@current_user, params[:time_log_entry]).create_entry
        if @time_log_entry.save
          render 'show'
        else
          @errors = @time_log_entry.errors.messages
          render 'show', status: 422
        end
      end

      private

      def set_entry
        @time_log_entry = TimeLogEntry.find params[:id]
      end

    end
  end
end
