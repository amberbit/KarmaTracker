module Api
  module V1

    class TimeLogEntriesController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      ##
      # Create new time log entry for given task.
      #
      # POST /api/v1/time_log_entries
      #
      # params:
      #   token - KarmaTracker API token
      #   time_log_entry[task_id] - ID of the task to which time should be added to
      #   time_log_entry[started_at] - start datetime of time period
      #   time_log_entry[stopped_at] - end datetime of time period
      #
      # = Examples
      #
      #   resp = conn.post("/api/v1/time_log_entries",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                   "time_log_entry" => {"task_id" => 1, "started_at" => "2000-01-01 01:00:00",
      #                                        "stopped_at" => "2000-01-01 02:00:00"})
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   =>{"time_log_entry": {"id":1,"task_id":1,"user_id":1,"running":false,"started_at":"2000-01-01T01:00:00Z",
      #                        "stopped_at":"2000-01-01T02:00:00Z","seconds":3600}}"
      #
      #   resp = conn.post("/api/v1/time_log_entries",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                   "time_log_entry" => {"task_id" => 1, "started_at" => "2000-01-01 01:00:00",
      #                                        "stopped_at" => "2000-01-01 02:00:00"})
      #   resp.status
      #   => 422
      #
      #   => "{"time_log_entry":{"id":null,"task_id":1,"user_id":1,"running":false,"started_at":"2000-01-01T01:00:00Z",
      #                          "stopped_at":"2000-01-01T02:00:00Z","seconds":0,
      #                          "errors":{"started_at":["should not overlap other time log entries"],
      #                                    "stopped_at":["should not overlap other time log entries"]}}}"
      #
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

      ##
      # Update time log entry record.
      #
      # PUT /api/v1/time_log_entries/:id
      #
      # params:
      #   token - KarmaTracker API token
      #   id - ID of time log entry to update
      #   time_log_entry[started_at] - start datetime of time period
      #   time_log_entry[stopped_at] - end datetime of time period
      #
      # = Examples
      #
      #   resp = conn.put("/api/v1/time_log_entries/1",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                   "time_log_entry" => {"started_at" => "2000-01-02 01:00:00", "stopped_at" => "2000-01-02 02:00:00"})
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => "{"time_log_entry":{"id":1,"task_id":1,"user_id":1,"running":false,"started_at":"2000-01-02T01:00:00Z",
      #                          "stopped_at":"2000-01-02T02:00:00Z","seconds":3600}}"
      #
      def update
        entry = TimeLogEntry.find params[:id]
        @time_log_entry = TimeLogEntriesFactory.new(entry, params[:time_log_entry]).update_entry

        if @time_log_entry.save
          render 'show'
        else
          @errors = @time_log_entry.errors.messages
          render 'show', status: 422
        end
      end

      ##
      # Remove time log entry record.
      #
      # DELETE /api/v1/time_log_entries/:id
      #
      # params:
      #   token - KarmaTracker API token
      #   id - ID of time log entry to destroy
      #
      # = Examples
      #
      #   resp = conn.delete("/api/v1/time_log_entries/1",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => "{"time_log_entry":{"id":1,"task_id":1,"user_id":1,"running":false,"started_at":"2000-01-02T01:00:00Z",
      #                          "stopped_at":"2000-01-02T02:00:00Z","seconds":3600}}"
      #
      #   resp = conn.delete("/api/v1/time_log_entries/9",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => "{"message":"Resource not found"}"
      #
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
