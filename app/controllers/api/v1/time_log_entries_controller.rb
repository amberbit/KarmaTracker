module Api
  module V1
    class TimeLogEntriesController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      ##
      # Get list of time log entries for particular user
      #
      # GET /api/v1/time_log_entries
      #
      # params:
      #   token - KarmaTracker API token
      #   project_id - ID of the project to filter results (optional)
      #   started_at - start datetime of timerange to filter time_log_entry period (optional)
      #   stopped_at - end datetime of timerange to filter time_log_entry period (optional)
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/time_log_entries",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #   resp.body
      #
      #    => {[{"time_log_entry": {"id"=>274, "task_id"=>231, "user_id"=>410, "running"=>false, "started_at"=>"2012-01-12T14:49:15Z",
      #             "stopped_at"=>"2013-04-12T14:50:15Z", "seconds"=>60}},
      #          {"time_log_entry": {"id"=>277, "task_id"=>231, "user_id"=>410, "running"=>true, "started_at"=>"2013-04-12T15:49:15Z",
      #             "stopped_at"=>nil, "seconds"=>0}}]}
      #
      #   resp = conn.get("/api/v1/time_log_entries",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4",
      #                   "started_at" => "2013-01-01 00:00:00")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #
      #    => {[{"time_log_entry": {"id"=>277, "task_id"=>231, "user_id"=>410, "running"=>true, "started_at"=>"2013-04-12T15:49:15Z",
      #             "stopped_at"=>nil, "seconds"=>0}}]}
      #
      def index
        begin
          scope = TimeLogEntry::Flex.search_time_log_entries(@current_user.id, params[:started_at].sub(' ', 'T'), params[:stopped_at].sub(' ', 'T')).count
        rescue Exception => e
          puts e.backtrace
        end

        #scope = scope.from_project(params[:project_id]) if params[:project_id].present?
       # scope = scope.after_timestamp(params[:started_at]) if params[:started_at].present?
       # scope = scope.before_timestamp(params[:stopped_at]) if params[:stopped_at].present?
        #TimeLogEntry::Flex.after_timestamp(params[:started_at]) if params[:started_at].present?
        #TimeLogEntry::Flex.before_timestamp(params[:stopped_at]) if params[:stopped_at].present?

        scope.sort! { |a,b| a.started_at <=> b.started_at }

        @time_log_entries = scope
        render 'index'
      end

      ##
      # Create new time log entry for given task. If no timerange is provided, it will create & start new time log entry.
      #
      # POST /api/v1/time_log_entries
      #
      # params:
      #   token - KarmaTracker API token
      #   time_log_entry[task_id] - ID of the task to which time should be added to
      #   time_log_entry[started_at] - start datetime of time period (optional)
      #   time_log_entry[stopped_at] - end datetime of time period (optional)
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
      #                   "time_log_entry" => {"task_id" => 1})
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => "{"time_log_entry": {"id":11,"task_id":1,"user_id":1,"running":true,
      #                           "started_at":"2013-04-12T13:09:05Z","stopped_at":null,"seconds":0}}"
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
        @time_log_entry = TimeLogEntriesFactory.new(new_entry, params[:time_log_entry]).create

        if !@time_log_entry.task || !@time_log_entry.task.project.in?(@current_user.projects)
          render json: {message: 'Resource not found'}, status: 404
        elsif @time_log_entry.save
          render '_show'
        else
          render '_show', status: 422
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
        @time_log_entry = TimeLogEntriesFactory.new(entry, params[:time_log_entry]).update

        if @time_log_entry.save
          render '_show'
        else
          @errors = @time_log_entry.errors.messages
          render '_show', status: 422
        end
      end

      ##
      # Stops any running time log entry.
      #
      # POST /api/v1/time_log_entries/stop
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.post("/api/v1/time_log_entries",
      #                   "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => "{"time_log_entry":{"id":1,"task_id":1,"user_id":1,"running":false,"started_at":"2000-01-02T01:00:00Z",
      #                          "stopped_at":"2000-01-02T02:00:00Z","seconds":3600}}"
      #
      def stop
        @time_log_entry = TimeLogEntry.stop_all(@current_user.id).first
        render '_show'
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
          render '_show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

    end
  end
end
