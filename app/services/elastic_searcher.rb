class ElasticSearcher
  class << self

    def projects(query = '', ids = [])
      Project::Flex.search_by_id_and_name(query.downcase.split, ids).
        map{ |found_element| found_element['_source'] }
    end

    def tasks(query = '', ids = [])
      Task::Flex.search_by_id_and_name(query.downcase.split, ids).
        map{ |found_element| found_element['_source'] }
    end

    #deMorgan'w law: if (StartA <= EndB) and (EndA >= StartB) then 2 date ranges overlap
    def time_log_entries(user_id, started_at, stopped_at, project_id)
      result = TimeLogEntry::Flex.by_user(user_id)
      if started_at.present? && stopped_at.present?
        result = result.after_stopped_at(started_at.sub(' ', 'T'))
        result = result.before_started_at(stopped_at.sub(' ', 'T'))
      end
      result = result.by_project(project_id) if project_id.present?
      result.map{ |found_element| found_element['_source'] }
    end
  end
end
