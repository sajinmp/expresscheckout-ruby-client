require_relative 'expresscheckout'
# Errors
require 'errors/juspay_error'
require 'errors/api_error'
require 'errors/api_connection_error'
require 'errors/invalid_request_error'
require 'errors/authentication_error'
require 'errors/invalid_arguement_error'

def request(method, url, parameters={})
  begin
    if $environment == 'production'
      $server = 'https://api.juspay.in'
    elsif $environment == 'sandbox'
      $server = 'https://sandbox.juspay.in'
    else
      raise 'ERROR: environment variable can be "production" or "staging"'
    end
    if method == 'GET'
      response = Unirest.get $server+url, headers: $version, auth: {:user => $api_key, :password => ''}, parameters: parameters
    else
      response = Unirest.post $server +url, headers: $version, auth: {:user => $api_key, :password => ''}, parameters: parameters
    end
    if (response.code >= 200 && response.code < 300)
      return response
    elsif ([400, 404].include? response.code)
      raise InvalidRequestError.new('Invalid Request', response.code, response.body)
    elsif (response.code == 401)
      raise AuthenticationError.new('Unauthenticated Request', response.code, response.body)
    else
      raise APIError.new('Invalid Request', response.code, response.body)
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
