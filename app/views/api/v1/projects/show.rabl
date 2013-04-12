object @project => :project
attributes :id, :name, :source_name, :source_identifier

node(:errors, unless: lambda{ |i| i.persisted? || i.valid? }) do |i|
  i.errors.messages
end
