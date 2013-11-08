class ElasticSearcher
  def self.search_projects(query = '', ids = [])
    Project::Flex.search_by_id_and_name(query.downcase.split, ids).
      map{ |found_element| found_element['_source'] }
  end
end
