module ApplicationHelper

  def perform_request type, url, params, headers
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    if type == 'post'
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request['content-type'] = 'application/json'
      request.body = params.to_json
    elsif type == 'delete'
      request = Net::HTTP::Delete.new(uri.request_uri, headers)
    else
      request = Net::HTTP::Get.new(uri.request_uri, headers)
    end
    http.request(request)
  end

end
