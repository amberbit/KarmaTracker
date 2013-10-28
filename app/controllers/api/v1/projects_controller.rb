module Api
  module V1
    class ProjectsController < ApplicationController
      include ::ApplicationHelper

      respond_to :json
      before_filter :restrict_access, except: [:pivotal_tracker_activity_web_hook, :git_hub_activity_web_hook]

      ##
      # Returns array of projects user participates in
      #
      # GET /api/v1/projects
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => [{"project": {"id":1, "name": "Sample project", "source_name": "Pivotal Tracker", "source_identifier": "123456", "task_count": "2"}},
      #       {"project": {"id":3, "name": "Some random name "source_name": "GitHub", "source_identifier": "42", "task_count": "0"}}]
      #
      def index
        @items_per_page = AppConfig.items_per_page
        @projects = @api_key.user.projects
        @projects = @projects.search_by_name(params[:query]) if params[:query].present?
        @projects = @projects.sort!{ |a,b| a.name.downcase <=> b.name.downcase }.
          paginate(page: params[:page], per_page: @items_per_page )
        render 'index'
      end

      ##
      # Returns single project
      #
      # GET /api/v1/projects/:id
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects/1", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"project": {"id":1, "name": "Sample project", "source_name": "Pivotal Tracker", "source_identifier": "123456", "task_count": "3"}}
      #
      #
      #   resp = conn.get("/api/v1/projects/7", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def show
        @project = Project.find_by_id(params[:id])

        if @project.present? && @api_key.user.projects.include?(@project)
          render '_show'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Returns a list of recent projects for a given user
      #
      # GET /api/v1/projects/recent
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects/recent", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => [{"project": {"id":1, "name": "Sample project", "source_name": "Pivotal Tracker", "source_identifier": "123456", "task_count": "2"}},
      #       {"project": {"id":3, "name": "Some random name "source_name": "GitHub", "source_identifier": "42", "task_count": "0"}}]
      #
      #   resp = conn.get("/api/v1/projects/recent", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def recent
        @projects = Project.recent(@current_user)

        if @projects[0].present?
          render 'index'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Triggers projects list refresh for all integrations of the user.
      # Refreshing runs in background, so the response is sent without waiting for it to finish.
      #
      # GET /api/v1/projects/refresh
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects/refresh", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"message": "Projects list refresh started"}
      #
      def refresh
        ProjectsFetcher.new.background.fetch_for_user(@api_key.user)
        render json: {message: 'Projects list refresh started'}, status: 200
      end

      ##
      # Triggers task list refresh for a single project.
      # Refreshing runs in background, so the response is sent without waiting for it to finish.
      #
      # GET /api/v1/projects/refresh_for_project/:id
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects/refresh_for_project/1", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"message": "Project list refresh started"}
      #
      #   resp = conn.get("/api/v1/projects/refresh_for_project/123", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def refresh_for_project
        project = Project.find(params[:id])
        integration = @api_key.user.integrations.joins(:participations).
          where('participations.project_id = ?', project.id).
          all(readonly: false).first
        if project && integration &&  @api_key.user.projects.include?(project)
          ProjectsFetcher.new.background.fetch_for_project(project, integration)
          render json: {message: 'Project list refresh started'}, status: 200
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Returns a list of all tasks for a given project if requesting user is a member of this project.
      #
      # GET /api/v1/projects/:id/tasks
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects/16/tasks", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
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
      #   resp = conn.get("/api/v1/projects/123/tasks", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def tasks
        project = Project.find_by_id(params[:id])
        if project && @api_key.user.projects.include?(project)
          @items_per_page = AppConfig.items_per_page
          @tasks = project.tasks
          @tasks = @tasks.search_by_name params[:query] if params[:query].present?
          @tasks = @tasks.paginate(page: params[:page], per_page: @items_per_page )
          render 'tasks'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Returns a list of current tasks for a given project if requesting user is a member of this project.
      #
      # GET /api/v1/projects/:id/current_tasks
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("/api/v1/projects/16/current_tasks", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {[{"task":{"id":1191,"project_id":16,"source_name":"Pivotal Tracker","source_identifier":"47519693","current_state":"accepted","story_type":"feature",
      #                 "current_task":true,"name":"As a user, I want to get authorized with my username and password and retrieve API token for further API access.","running":false}}]}
      #
      #   resp = conn.get("/api/v1/projects/123/current_tasks", "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def current_tasks
        project = Project.find_by_id(params[:id])
        if project.present? && @api_key.user.projects.include?(project)
          @items_per_page = AppConfig.items_per_page
          @tasks = project.tasks.current
          @tasks = @tasks.search_by_name params[:query] if params[:query].present?
          @tasks = @tasks.paginate(page: params[:page], per_page: @items_per_page )
          render 'tasks'
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Process issues creation/update feed from GitHub hook.
      #
      # POST /api/v1/projects/git_hub_activity_web_hook
      #
      # params:
      #   token - unique token web hook token assigned to a project.
      #
      # = Examples
      #
      #   resp = conn.post do |req|
      #     req.url "/api/v1/projects/1/git_hub_activity_web_hook?token=correct"
      #     req.headers['X-Github-Event'] = 'issues'
      #     req.body = '{
      #                  "action":"opened",
      #                  "issue":{"id":123,"number":1,"title":"test","state":"open",...},
      #                  "repository":{
      #                    "id":12345678,
      #                    "name":"repo",
      #                    "full_name":"owner/repo",...},
      #                  "sender":{
      #                    "login":"sender",
      #                    "id":12345678,
      #                    "type":"User",...}}'
      #   end
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"message": "Activity processed"}
      #
      def git_hub_activity_web_hook
        if project = Project.where(source_name: 'GitHub').find_by_web_hook_token(params[:token])
          GitHubWebHooksManager.new({project: project}).process_feed request
          render json: {message: 'Activity processed'}, status: 200
        else
          render json: {message: 'Invalid token'}, status: 401
        end
      end

      # Pivotal Tracker activity web hook
      #
      # POST /api/v1/projects/:id/pivotal_tracker_activity_web_hook
      #
      # params:
      #   token - unique token web hook token assigned to a project; can be retrieved by sending get request to /api/v1/projects/:id/pivotal_tracker_activity_web_hook_url
      #
      # = Examples
      #
      #   resp = conn.post do |req|
      #     req.url "/api/v1/projects/16/pivotal_tracker_activity_web_hook?token=correct"
      #     req.body = '<?xml version="1.0" encoding="UTF-8"?> <activity> <id type="integer">12345</id> <version type="integer">4</version>
      #                 <event_type>story_create</event_type> <occurred_at type="datetime">2013/04/19 08:31:27 UTC</occurred_at>
      #                 <author>Darth Vader</author> <project_id type="integer">16</project_id> <description>Darth Vader added &quot;Building Death Star&quot;</description>
      #                 <stories type="array"> <story> <id type="integer">1231231</id> <url>http://www.pivotaltracker.com/services/v3/projects/16/stories/1231231</url>
      #                 <name>Build Death Star</name><story_type>feature</story_type> <current_state>unscheduled</current_state> <requested_by>Imperator Palpatine</requested_by>
      #                 </story> </stories> </activity>'
      #   end
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"message": "Activity processed"}
      #
      #   resp = conn.post do |req|
      #     req.url "/api/v1/projects/1/pivotal_tracker_activity_web_hook?token=correct"
      #     req.body = '<?xml version="1.0" encoding="UTF-8"?> <activity> <id type="integer">12345</id> <version type="integer">4</version>
      #                 <event_type>story_create</event_type> <occurred_at type="datetime">2013/04/19 08:31:27 UTC</occurred_at>
      #                 <author>Darth Vader</author> <project_id type="integer">16</project_id> <description>Darth Vader added &quot;Building Death Star&quot;</description>
      #                 <stories type="array"> <story> <id type="integer">1231231</id> <url>http://www.pivotaltracker.com/services/v3/projects/16/stories/1231231</url>
      #                 <name>Building Death Star</name> <story_type>feature</story_type> <current_state>unscheduled</current_state> <requested_by>Imperator Palpatine</requested_by>
      #                 </story> </stories> </activity>'
      #   end
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      #   resp = conn.post do |req|
      #     req.url "/api/v1/projects/1/pivotal_tracker_activity_web_hook?token=wrong"
      #     req.body = '<?xml version="1.0" encoding="UTF-8"?> <activity> <id type="integer">12345</id> <version type="integer">4</version>
      #                 <event_type>story_create</event_type> <occurred_at type="datetime">2013/04/19 08:31:27 UTC</occurred_at>
      #                 <author>Darth Vader</author> <project_id type="integer">16</project_id> <description>Darth Vader added &quot;Building Death Star&quot;</description>
      #                 <stories type="array"> <story> <id type="integer">1231231</id> <url>http://www.pivotaltracker.com/services/v3/projects/16/stories/1231231</url>
      #                 <name>Building Death Star</name> <story_type>feature</story_type> <current_state>unscheduled</current_state> <requested_by>Imperator Palpatine</requested_by>
      #                 </story> </stories> </activity>'
      #   end
      #
      #   resp.status
      #   => 401
      #
      #   resp.body
      #   => {"message": "Invalid token"}
      #
      def pivotal_tracker_activity_web_hook
        project = Project.find(params[:id])
        if params[:token].blank? || params[:token] != project.web_hook_token
          render json: {message: 'Invalid token'}, status: 401
        elsif project && PivotalTrackerActivityWebHook.new(project).process_request(request.body)
          render json: {message: 'Activity processed'}, status: 200
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end

      ##
      # Returns web hook URL, containing authentication token
      #
      # GET /api/v1/projects/:id/pivotal_tracker_activity_web_hook_url
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("api/v1/projects/1/pivotal_tracker_activity_web_hook_url, "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => {"url": "http://some-host.com/api/v1/projects/1/pivotal_tracker_activity_web_hook?token=W3bH0oKt043n
      #
      #   resp = conn.get("api/v1/projects/123/pivotal_tracker_activity_web_hook_url, "token" => "dcbb7b36acd4438d07abafb8e28605a4"")
      #
      #   resp.status
      #   => 404
      #
      #   resp.body
      #   => {"message": "Resource not found"}
      #
      def pivotal_tracker_activity_web_hook_url
        project = Project.find(params[:id])
        if project.users.include?(@api_key.user) && project.source_name == 'Pivotal Tracker'
          render json: {url: "#{pivotal_tracker_activity_web_hook_api_v1_project_url(project)}?token=#{project.web_hook_token}"}, status: 200
        else
          render json: {message: 'Resource not found'}, status: 404
        end
      end


      ##
      # Returns user's other project names on which other users are currently also working.
      #
      # GET /api/v1/projects/also_working
      #
      # params:
      #   token - KarmaTracker API token
      #
      # = Examples
      #
      #   resp = conn.get("api/v1/projects/also_working, "token" => "dcbb7b36acd4438d07abafb8e28605a4")
      #
      #   resp.status
      #   => 200
      #
      #   resp.body
      #   => { 'Project name' => [11, { 'Task name' => { { email: email@example.com, gravatar: gravatar_url}, { email: email2@example.com, gravatar: gravatar_url2}},
      #                          { 'Task name2' => { { email: email3@example.com, gravatar: gravatar_url3}}}],
      #        'Project name2' => { 'Task name3' => [12, { { email: email4@example.com, gravatar: gravatar_url4}}}}]
      #
      #
      #   resp = conn.get("api/v1/projects/also_working, "token" => "dcbb7b36acd4438d07abafb8e28605a4"")
      #
      #   resp.status
      #   => 204
      #
      #   resp.body == ""
      #   204 doesn't return a body
      #
      def also_working
        if @api_key.user && @api_key.user.projects.present?
          ids = @api_key.user.projects.map(&:id)
          render json: also_working_hash(ids), status: 200
        else
          render json: nil, status: 204
        end
      end
    end
  end
end
