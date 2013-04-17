json.array! @users do |u|
  json.partial! "api/v1/users/show", user: u
end
