require 'mercury_parser/error'

module MercuryParser
  module Request

    # Performs a HTTP Get request
    def get(path, params={})
      request(:get, path, params)
    end

    # Performs a HTTP POST request
    def post(path, params={})
      request(:post, path, params)
    end

    private

    # Returns a Faraday::Response object
    #
    # @return [Faraday::Response]
    def request(method, path, params = {})
      raise MercuryParser::Error::ConfigurationError.new("Please configure MercuryParser.api_key first") if api_key.nil?

      connection_options = {}
      connection_options[:url] = method == :get ? MercuryParser.api_endpoint : MercuryParser.api_html_endpoint

      begin
        response = connection(connection_options).send(method) do |req|
          req.url(path, params.except(:html))
          req.headers['Content-Type'] = 'application/json'
          req.headers['x-api-key'] = api_key
          unless method == :get && params.empty?
            req.body = JSON.dump(params)
          end
        end
      rescue Faraday::Error::ClientError => error
        if error.is_a?(Faraday::Error::ClientError)
          raise MercuryParser::Error::ClientError.new(error)
        else
          raise MercuryParser::Error::RequestError.new(error)
        end
      end

      response.body
    end
  end # Request
end
