class Factory

  def initialize(object, params={})
    @object = object
    @params = params
  end

  def create
    raise NotImplementedError
  end

  def update
    raise NotImplementedError
  end

  private

  def valid_attributes attributes
    @params.select do |key, value|
      key.to_s.in?(attributes)
    end
  end

end
