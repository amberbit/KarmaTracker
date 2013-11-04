project ||= @project

json.project do
  json.id project['id']
  json.name project['name']
  json.source_name project['source_name']
  json.source_identifier project['source_identifier']
  json.task_count project['task_count']

  if project.class == ActiveRecord::Base && !project.persisted? && !project.valid?
    json.errors project.errors.messages
  end
end
