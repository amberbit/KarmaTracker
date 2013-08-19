json.projects @projects, partial: 'api/v1/projects/show', as: :project
if @projects.respond_to?(:total_entries)
  json.total_count @projects.total_entries
end
