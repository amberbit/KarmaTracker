def api_get action, params={}, version="1"
  get "/api/v#{version}/#{action}", params
  @response = JSON.parse(response.body) rescue {}
end
