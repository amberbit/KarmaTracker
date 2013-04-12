class TimeLogEntriesFactory

  VALID_ATTRIBUTES = %w[started_at stopped_at]
  VALID_CREATE_ATTRIBUTES = VALID_ATTRIBUTES + %w[task_id]

  def initialize(entry, options)
    @entry = entry
    @options = options
  end

  def create_entry
    @entry.assign_attributes valid_attributes(VALID_CREATE_ATTRIBUTES)
    @entry
  end

  def update_entry
    @entry.assign_attributes valid_attributes(VALID_ATTRIBUTES)
    @entry
  end

  private

  def valid_attributes attributes
    @options.select do |key, value|
      key.to_s.in?(attributes)
    end
  end

end
