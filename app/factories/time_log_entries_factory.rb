class TimeLogEntriesFactory

  VALID_ATTRIBUTES = %w[task_id started_at stopped_at seconds]

  def initialize(user, options)
    @user = user
    @options = options
  end

  def create_entry
    attrs = @options.select do |key, value|
      key.to_s.in?(VALID_ATTRIBUTES)
    end

    @user.time_log_entries.build(attrs)
  end

end
