def api_get action, params={}, version="1"
  get "/api/v#{version}/#{action}", params
end

def api_post action, params={}, version="1"
  post "/api/v#{version}/#{action}", params
end

def api_delete action, params={}, version="1"
  delete "/api/v#{version}/#{action}", params
end

