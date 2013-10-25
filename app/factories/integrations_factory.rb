class IntegrationsFactory < Factory

  VALID_CLASSES = %w[PivotalTrackerIntegration GitHubIntegration]
  VALID_ATTRIBUTES = %w[api_key username email password user_id]

  def create
    return Integration.new unless VALID_CLASSES.include?(@object.class.to_s)

    attrs = valid_attributes(VALID_ATTRIBUTES)
    @object.assign_attributes attrs

    @object
  end

  def update
    @object
  end

end
