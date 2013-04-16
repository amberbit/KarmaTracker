class IdentitiesFactory

  VALID_CLASSES = %w[PivotalTrackerIdentity GitHubIdentity]
  VALID_ATTRIBUTES = %w[name api_key email password user_id]

  def initialize(object, params={})
    @object = object
    @params = params
  end

  def create_identity
    return Identity.new unless VALID_CLASSES.include?(@object.class.to_s)

    attrs = valid_attributes(VALID_ATTRIBUTES)
    @object.assign_attributes attrs

    @object
  end

  def update_identity
    @object.assign_attributes valid_attributes(%w[name])
    @object
  end

  private

  def valid_attributes attributes
    @params.select do |key, value|
      key.to_s.in?(attributes)
    end
  end

end
