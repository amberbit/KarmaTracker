object @time_log_entry
attributes :id, :task_id, :user_id, :running, :started_at, :stopped_at, :seconds

node(:errors, if: @errors.present? ) do |i|
  i.errors.messages
end
