json.projects @projects, partial: 'api/v1/projects/show', as: :project
json.total_count @projects.total_entries
