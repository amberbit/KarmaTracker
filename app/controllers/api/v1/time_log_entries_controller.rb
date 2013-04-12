module Api
  module V1

    class TimeLogEntriesController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def create
        new_entry = @current_user.time_log_entries.build
        @time_log_entry = TimeLogEntriesFactory.new(new_entry, params[:time_log_entry]).create_entry

        if @time_log_entry.save
          render 'show'
        else
          @errors = @time_log_entry.errors.messages
          render 'show', status: 422
        end
      end

      def update
        entry = TimeLogEntry.find params[:id]
        @time_log_entry = TimeLogEntriesFactory.new(entry, params[:time_log_entry]).create_entry

        if @time_log_entry.save
          render 'show'
        else
          @errors = @time_log_entry.errors.messages
          render 'show', status: 422
        end
      end

      def destroy
        @time_log_entry = TimeLogEntry.find params[:id]

        if @time_log_entry.user == @current_user
          @time_log_entry.delete
          render 'show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

    end
  end
end
