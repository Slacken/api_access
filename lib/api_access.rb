require 'net/http'
require 'net/https'
require 'uri'
require 'json'

# require "api_access/version"

class ApiAccess
  class << self
    %w{get post}.each do |method|
      %w{JSON XML}.each do |format|
        define_method "#{method}#{format}", ->(url, params={}) do
          request(url,params, method, format)
        end
      end
      alias_method method, "#{method}JSON"
    end


    private
    def request(url,request_params,method = 'get', format = nil)
      uri = URI(url)
      klass = (uri.scheme == 'https' ? Net::HTTPS : Net::HTTP)
      if method == 'get'
        uri.query = (uri.query.nil? ? '' : (uri.query + "&")) + URI.encode_www_form(request_params)
        response = klass.get_response(uri)
      else
        response = klass.post_form(uri, request_params)
      end
      if response.kind_of? Net::HTTPSuccess
        format == 'JSON' ? JSON.parse(response.body) : response.body
      else
        nil
      end
    end
  end
end
