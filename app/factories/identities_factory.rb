class IdentitiesFactory

  VALID_CLASSES = %w[PivotalTracker GitHub]
  VALID_ATTRIBUTES = %w[name api_key email password]

  def initialize(options)
    @options = options
  end

  def create_identity
    klass = get_identity_class
    return nil unless klass.present?

    attrs = @options.select do |key, value|
      key.to_s.in?(VALID_ATTRIBUTES)
    end

    klass.new(attrs)
  end

  private

  def get_identity_class
    klass = @options[:service].camelize

    return nil unless VALID_CLASSES.include?(klass)

    klass.concat('Identity') unless klass =~ /Identity\z/
    klass.constantize
  end
end
