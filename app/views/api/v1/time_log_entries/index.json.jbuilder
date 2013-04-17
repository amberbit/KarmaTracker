json.array! @time_log_entries do |tl|
  json.partial! "api/v1/time_log_entries/show", time_log_entry: tl
end
