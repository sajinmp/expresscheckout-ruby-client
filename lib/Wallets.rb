require_relative 'util'

class Wallets

  # noinspection ALL
  class Wallet

    attr_reader :id, :wallet, :object, :token, :linked, :current_balance, :last_refresh

    def initialize(options = {})
      @id = get_arg(options, 'id')
      @object = get_arg(options, 'object')
      @wallet = get_arg(options, 'wallet')
      @token = get_arg(options, 'token')
      @linked = get_arg(options, 'linked')
      @current_balance = get_arg(options, 'current_balance')
      @last_refresh = get_arg(options, 'last_refreshed')
    end

  end

  def Wallets.create(options={})
    customer_id = get_arg(options, :customer_id)
    gateway = get_arg(options, :gateway)

    if customer_id == NIL or customer_id == '' or gateway == NIL or gateway == ''
      raise InvalidArguementError.new("ERROR: `customer_id` and `gateway` are required parameters for Wallets.create()")
    end

    url = "/customers/#{customer_id}/wallets"

    method = 'POST'
    parameters = {
        :gateway => gateway
    }
    response = api_request(method,url,parameters)
    wallet = Wallet.new(response.body)
    return wallet
  end

  def Wallets.create_and_authenticate(options={})
    customer_id = get_arg(options, :customer_id)
    gateway = get_arg(options, :gateway)

    if customer_id == NIL or customer_id == '' or gateway == NIL or gateway == ''
      raise InvalidArguementError.new("ERROR: `customer_id` and `gateway` are required parameters for Wallets.create_and_authenticate()")
    end

    url = "/customers/#{customer_id}/wallets"

    method = 'POST'
    parameters = {
        :command => 'authenticate',
        :gateway => gateway
    }
    response = api_request(method,url,parameters)
    wallet = Wallet.new(response.body)
    return wallet
  end

  def Wallets.list(options={})
    order_id = get_arg(options, :order_id)
    customer_id = get_arg(options, :customer_id)

    if (customer_id == NIL or customer_id == '') and (order_id == NIL or order_id == '')
      raise InvalidArguementError.new("ERROR: `customer_id` or `order_id` is required parameter for Wallets.list()")
    end

    if customer_id
      url = "/customers/#{customer_id}/wallets"
    else
      url = "/orders/#{order_id}/wallets"
    end

    method = 'GET'
    response = Array(api_request(method,url,{}).body['list'])
    wallets = []
    i=0
    while i != response.count
      wallet = Wallet.new(response[i])
      wallets.push(wallet)
      i+=1
    end
    return wallets
  end

  def Wallets.refresh_balance(options={})
    customer_id = get_arg(options, :customer_id)

    if customer_id == NIL or customer_id == ''
      raise InvalidArguementError.new("ERROR: `customer_id` is required parameter for Wallets.refresh_balance()")
    end

    url = "/customers/#{customer_id}/wallets/refresh-balances"
    method = 'GET'
    response = Array(api_request(method,url,{}).body['list'])
    wallets = []
    i=0
    while i != response.count
      wallet = Wallet.new(response[i])
      wallets.push(wallet)
      i+=1
    end
    return wallets
  end

  def Wallets.refresh_by_wallet_id(options={})
    wallet_id = get_arg(options, :wallet_id)

    if wallet_id == NIL or wallet_id == ''
      raise InvalidArguementError.new("ERROR: `wallet_id` is required parameter for Wallets.refresh_by_wallet_id()")
    end

    url = "/wallets/#{wallet_id}"

    method = 'GET'
    parameters = {
        :command => 'refresh'
    }
    response = api_request(method,url,parameters)
    wallet = Wallet.new(response.body)
    return wallet
  end


  def Wallets.authenticate(options={})
    wallet_id = get_arg(options, :wallet_id)

    if wallet_id == NIL or wallet_id == ''
      raise InvalidArguementError.new("ERROR: `wallet_id` is required parameter for Wallets.authenticate()")
    end

    url = "/wallets/#{wallet_id}"

    method = 'POST'
    parameters = {
        :command => 'authenticate'
    }
    response = api_request(method,url,parameters)
    wallet = Wallet.new(response.body)
    return wallet
  end

  def Wallets.link(options={})
    wallet_id = get_arg(options, :wallet_id)
    otp = get_arg(options, :otp)

    if wallet_id == NIL or wallet_id == '' or otp == NIL or otp == ''
      raise InvalidArguementError.new("ERROR: `wallet_id` and `otp` are required parameters for Wallets.link()")
    end

    url = "/wallets/#{wallet_id}"

    method = 'POST'
    parameters = {
        :command => 'link',
        :otp => otp
    }
    response = api_request(method,url,parameters)
    wallet = Wallet.new(response.body)
    return wallet
  end

  def Wallets.delink(options={})
    wallet_id = get_arg(options, :wallet_id)

    if wallet_id == NIL or wallet_id == ''
      raise InvalidArguementError.new("ERROR: `wallet_id` is required parameter for Wallets.delink()")
    end

    url = "/wallets/#{wallet_id}"

    method = 'POST'
    parameters = {
        :command => 'delink'
    }
    response = api_request(method,url,parameters)
    wallet = Wallet.new(response.body)
    return wallet
  end
end
