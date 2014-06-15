require 'net/http'
require 'net/https'
require 'uri'
require 'json'

# require "api_access/version"

class ApiAccess
  class << self
    def get(url, get_params = {})
      request(url,get_params,'get')
    end

    def post(url, post_params = {})
      request(url,post_params,'post')
    end

    # assume get json data
    def request(url,request_params,method = 'get')
      uri = URI(url)
      klass = (uri.scheme == 'https' ? Net::HTTPS : Net::HTTP)
      if method == 'get'
        uri.query = (uri.query.nil? : '' ? (uri.query + "&")) + URI.encode_www_form(request_params)
        response = klass.get_response(uri)
      else
        response = klass.post_form(uri, request_params)
      end
      if response.kind_of? Net::HTTPSuccess
        JSON.parse(response.body)
      else
        nil
      end
    end
  end
end
