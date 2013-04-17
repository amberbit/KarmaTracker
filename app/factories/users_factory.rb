class UsersFactory < Factory

  VALID_ATTRIBUTES = %w[email password]

  def create
    attrs = valid_attributes(VALID_ATTRIBUTES)
    @object.assign_attributes attrs

    @object
  end

  def update
    @object.assign_attributes valid_attributes(VALID_ATTRIBUTES)
    @object
  end

end
