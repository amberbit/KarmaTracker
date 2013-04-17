class TimeLogEntriesFactory < Factory

  def create
    if @params['started_at'].present? && @params['stopped_at'].present?
      attrs = valid_attributes(%w[started_at stopped_at task_id])
    else
      TimeLogEntry.stop_all @object.user_id
      attrs = valid_attributes(%w[task_id])
      @object.start
    end
    @object.assign_attributes attrs

    @object
  end

  def update
    @object.assign_attributes valid_attributes(%w[started_at stopped_at])
    @object
  end

end
