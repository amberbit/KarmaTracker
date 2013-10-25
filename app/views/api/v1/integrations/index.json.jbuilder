json.array! @integrations do |i|
  json.partial! "api/v1/integrations/show", integration: i
end
