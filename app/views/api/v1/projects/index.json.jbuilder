json.array! @projects do |p|
  json.partial! "api/v1/projects/show", project: p
end
