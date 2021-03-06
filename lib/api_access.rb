require 'net/http'
require 'net/https'
require 'uri'
require 'json'

# require "api_access/version"

class ApiAccess
  class << self
    %w{get post}.each do |method|
      %w{json xml}.each do |format|
        define_method "#{method}_#{format}", ->(url, params={}) do
          request(url,params, method, format)
        end

        define_method "batch_#{method}_#{format}", ->(urls, key_params, cocurrence = 10) do
          values = {}
          # two kind of batching: one url with many params
          if urls.is_a? String
            url = urls
            key_params.each_slice(cocurrence){ |group|
              threads = {}
              group.each do |key, params| # [key] array or key=> params hash
                params = {} if params.nil?
                threads[key] = Thread.new(params) do |param|
                  request(url, param, method, format)
                end
                threads.each_pair{|k, thread| values[k] = thread.value}
              end
            }
          # and, many urls with one param
          else
            params = key_params || {}
            urls.each_slice(cocurrence){|group|
              threads = {}
              group.each do |key, url|
                threads[key] = Thread.new(params) do |param|
                  request(url, param, method, format)
                end
                threads.each_pair{|k, thread| values[k] = thread.value}
              end
            }
          end
          values
        end
      end

      alias_method method, "#{method}_json"
      alias_method "batch_#{method}", "batch_#{method}_json"
    end

    private
    def request(url,request_params,method = 'get', format = nil)
      uri = URI(url)
      klass = (uri.scheme == 'https' ? Net::HTTPS : Net::HTTP)
      begin
        if method == 'get'
          uri.query = (uri.query.nil? ? '' : (uri.query + "&")) + URI.encode_www_form(request_params)
          response = klass.get_response(uri)
        else
          response = klass.post_form(uri, request_params)
        end
      rescue Exception => e
        puts e.message
        return nil
      end
      
      if response.kind_of? Net::HTTPSuccess
        format == 'json' ? JSON.parse(response.body) : response.body
      else
        nil
      end
    end
  end
end
