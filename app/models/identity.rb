class Identity < ActiveRecord::Base
  attr_accessible :name, :api_key

  validates_uniqueness_of :api_key, :scope => :type

  belongs_to :user

  def service_name
    # overwrite in subclass
  end

  def self.by_service(service)
    service = service.camelize
    sevice = service.concat('Identity') unless service =~ /Identity\z/
    where(type: service)
  end
end
