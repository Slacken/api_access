require "api_access/version"
require 'net/http'
require 'net/https'
require 'uri'

class ApiAccess
  class << self
    def get(url, get_params)
      request(url,get_params,'get')
    end

    def post(url, post_params)
      request(url,post_params,'post')
    end

    # assume get json data
    def request(url,request_params,method = 'get')
      uri = URI(url)
      http = Net::HTTP.new(uri.host,uri.port)
      http.use_ssl = (uri.scheme == 'https')
      if method == 'get'
        query = URI.encode_www_form(request_params)
        response = http.get("#{uri.path}?#{query}")
      else
        response = http.post(uri.path,URI.encode_www_form(request_params))
      end
      if response.kind_of? Net::HTTPSuccess
        JSON.parse(response.body)
      else
        nil
      end
    end
  end
end
