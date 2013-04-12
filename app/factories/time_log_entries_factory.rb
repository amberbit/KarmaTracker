class TimeLogEntriesFactory

  def initialize(entry, params)
    @entry = entry
    @params = params
  end

  def create_entry
    if @params['started_at'].present? && @params['stopped_at'].present?
      attrs = valid_attributes(%w[started_at stopped_at task_id])
    else
      TimeLogEntry.stop_all @entry.user_id
      attrs = valid_attributes(%w[task_id])
      @entry.start
    end
    @entry.assign_attributes attrs

    @entry
  end

  def update_entry
    @entry.assign_attributes valid_attributes(%w[started_at stopped_at])
    @entry
  end

  private

  def valid_attributes attributes
    @params.select do |key, value|
      key.to_s.in?(attributes)
    end
  end

end
