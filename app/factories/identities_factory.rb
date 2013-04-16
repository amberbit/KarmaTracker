class IdentitiesFactory

  VALID_CLASSES = %w[PivotalTrackerIdentity GitHubIdentity]
  VALID_ATTRIBUTES = %w[name api_key username email password user_id]

  def initialize(klass, options)
    @klass = klass
    @options = options
  end

  def create_identity
    return Identity.new unless VALID_CLASSES.include?(@klass.to_s)

    attrs = @options.select do |key, value|
      key.to_s.in?(VALID_ATTRIBUTES)
    end

    @klass.new(attrs)
  end

end
