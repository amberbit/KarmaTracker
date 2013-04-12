class TimeLogEntriesFactory

  VALID_ATTRIBUTES = %w[task_id started_at stopped_at seconds]

  def initialize(entry, options)
    @entry = entry
    @options = options
  end

  def create_entry
    attrs = @options.select do |key, value|
      key.to_s.in?(VALID_ATTRIBUTES)
    end

    @entry.assign_attributes(attrs)
    @entry
  end

end
