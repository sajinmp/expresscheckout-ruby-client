require_relative 'expresscheckout'
# Errors
require 'errors/juspay_error'
require 'errors/api_error'
require 'errors/api_connection_error'
require 'errors/invalid_request_error'
require 'errors/authentication_error'
require 'errors/invalid_arguement_error'

def api_request(method, url, parameters={})
  begin
    if $environment == 'production'
      $server = 'https://api.juspay.in'
    elsif $environment == 'staging'
      $server = 'https://sandbox.juspay.in'
    else
      raise InvalidArguementError.new('ERROR: environment variable can be "production" or "staging"')
    end
    if $api_key == nil
      raise AuthenticationError.new("ERROR: API key missing. Please specify api_key.")
    end
    $headers = {
        'version' => $api_version,
        'User-Agent' => "Ruby SDK #{Expresscheckout::VERSION}"
    }
    if method == 'GET'
      response = Unirest.get $server+url, headers: $headers, auth: {:user => $api_key, :password => ''}, parameters: parameters
    else
      response = Unirest.post $server +url, headers: $headers, auth: {:user => $api_key, :password => ''}, parameters: parameters
    end
    if (response.code >= 200 && response.code < 300)
      return response
    elsif ([400, 404].include? response.code)
      raise InvalidRequestError.new('Invalid Request', response.code, response.body, parameters)
    elsif (response.code == 401)
      raise AuthenticationError.new('Unauthenticated Request', response.code, response.body, parameters)
    else
      raise APIError.new('Invalid Request', response.code, response.body, parameters)
    end
  rescue IOError
    raise APIConnectionError.new('Connection error')
  rescue SocketError
    raise APIConnectionError.new('Socket error. Failed to connect.')
  end
end

def get_arg(options = {}, param)
  if options == NIL
    NIL
  elsif options.key?(param)
    options[param]
  else
    NIL
  end
end

def check_param(options = {}, param)
  options.each do |key, _|
    if key.include?(param)
      return true
    end
  end
  false
end
