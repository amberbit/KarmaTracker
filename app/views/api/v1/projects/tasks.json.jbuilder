json.tasks @tasks, partial: 'api/v1/tasks/show', as: :task
if @tasks.respond_to?(:total_entries)
  json.total_count @tasks.total_entries
end
