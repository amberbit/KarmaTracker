def api_get action, params={}, version="1"
  query = params.empty? ? "" : ("?" + params.map{|k,v| "#{k}=#{CGI.escape v}"}.join("&"))
  get "/api/v#{version}/#{action}#{query}"
end
