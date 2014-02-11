task ||= @task
log_entry ||= @log_entry

json.id task['id']
json.project_id task['project_id']
json.source_name task['source_name']
json.source_identifier task['source_identifier']
json.current_state task['current_state']
json.story_type task['story_type']
json.current_task task['current_task']
json.name task['name']
json.running Task.running?(task['id'], @current_user.id)
json.started_at log_entry.started_at if log_entry
json.visible true
