module ApplicationHelper

  def perform_request type, url, params, headers
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    if type == 'post'
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request['content-type'] = 'application/json'
      request.body = params.to_json
    elsif type == 'delete'
      request = Net::HTTP::Delete.new(uri.request_uri, headers)
    else
      request = Net::HTTP::Get.new(uri.request_uri, headers)
    end
    http.request(request)
  end

  #TODO: use inject instead of each?
  #TODO: move to view!
  def also_working_hash(ids)
    projects = {}
    Project.also_working(ids).each do |project|
      tasks = {}
      project.tasks.joins(:time_log_entries).where('time_log_entries.running = ?', true).uniq.each do |task|
        users = task.time_log_entries.joins(:user).running.reject{ |tle| tle.user == @api_key.user}
        .map{ |tle| { id: tle.user.id,
                      email: tle.user.email,
                      gravatar: tle.user.gravatar_url }}
        next if users.empty?
        tasks[task.name] = [task.id, users]
      end
      next if tasks.empty?
      projects[project.name] = [project.id, tasks]
    end
    projects
  end
end
