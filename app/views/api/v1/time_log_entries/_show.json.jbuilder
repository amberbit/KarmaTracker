time_log_entry ||= @time_log_entry

json.time_log_entry do
  json.id time_log_entry['id']
  json.task_id time_log_entry['task_id']
  json.user_id time_log_entry['user_id']
  json.running time_log_entry['running']
  json.started_at time_log_entry['started_at']
  json.stopped_at time_log_entry['stopped_at']
  json.seconds time_log_entry['seconds']

  if time_log_entry.class == TimeLogEntry && time_log_entry.errors.messages.present?
    json.errors time_log_entry.errors.messages
  end
end
