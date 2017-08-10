require_relative 'util'

class Payments

  class Transaction

    attr_reader :order_id, :payment, :status, :txn_id
    class Payment
      attr_reader :authentication
      def initialize(options={})
        auth = Authentication.new(get_arg(options,'authentication'))
        @authentication = auth
      end

      class Authentication
        attr_reader :url, :method, :params
        def initialize(options={})
          @method = get_arg(options, 'method')
          @url = get_arg(options, 'url')
          @params = get_arg(options, 'params')
        end
      end

    end
    def initialize(options={})
      @order_id = get_arg(options, 'order_id')
      @txn_id = get_arg(options, 'txn_id')
      @status = get_arg(options, 'status')
      @payment = Payment.new(get_arg(options, 'payment'))
    end

  end

  class PaymentMethod

    attr_reader :payment_method_type, :payment_method, :description
    def initialize(options={})
      @payment_method_type = get_arg(options, 'payment_method_type')
      @payment_method = get_arg(options, 'payment_method')
      @description = get_arg(options, 'description')
    end

  end

  def Payments.create_card_payment(options={})
    method = 'POST'
    url = '/txns'
    parameters = {
      :payment_method_type => "CARD",
      :format => 'json'
    }
    required_args = {}
    Array[:order_id, :merchant_id, :card_token, :payment_method_type, :card_number, :name_on_card,
          :card_exp_year, :card_exp_month, :card_security_code, :save_to_locker, :redirect_after_payment,
          :format].each do |key|
      required_args.store(key,'False')
    end
    options.each do |key, value|
      parameters.store(key,value)
      required_args[key] = 'True'
    end
    
    # Either token or card number validation    
    if required_args[:card_token] == 'False' and !([:card_number, :name_on_card, :card_exp_year,:card_exp_month, :card_security_code, :save_to_locker].all? {|s| options.key? s})
        raise InvalidArguementError.new("ERROR: Either [card_token] or [card_number, name_on_card, card_exp_year, card_exp_month, card_security_code, save_to_locker] are required arguments for Payments.create_card_payment()")
    end
        
    Array[:order_id, :merchant_id, :redirect_after_payment].each do |key|
      if required_args[key] == 'False'
        raise InvalidArguementError.new("ERROR: #{key} is a required argument for Payments.create_card_payment")
      end
    end
    parameters.each do |key, _|
      unless Array[:order_id, :merchant_id, :payment_method_type, :payment_method, :card_token, :card_number, :name_on_card,
                   :card_exp_year, :card_exp_month, :card_security_code, :save_to_locker, :redirect_after_payment,
                   :format].include?(key)
        puts " #{key} is an invalid argument for Payments.create_card_payment"
      end
    end
    if required_args[:save_to_locker] == 'True' && parameters[:save_to_locker] != true and parameters[:save_to_locker] != false
      raise InvalidArguementError.new("ERROR: 'save_to_locker' should be true or false")
    end
    if parameters[:redirect_after_payment] != true and parameters[:redirect_after_payment] != false
      raise InvalidArguementError.new("ERROR: 'redirect_after_payment' should be true or false")
    end

    response = api_request(method,url,parameters)
    payment = Transaction.new(response.body)
    return payment
  end

  def Payments.create_net_banking_payment(options={})
    method = 'POST'
    url = '/txns'
        parameters = {
      :payment_method_type => "NB",
      :format => 'json'
    }
    required_args = {}
    Array[:order_id, :merchant_id, :payment_method, :redirect_after_payment].each do |key|
      required_args.store(key,'False')
    end
    options.each do |key, value|
      parameters.store(key,value)
      required_args[key] = 'True'
    end
    Array[:order_id, :merchant_id, :payment_method, :redirect_after_payment].each do |key|
      if required_args[key] == 'False'
        raise InvalidArguementError.new("ERROR: #{key} is a required argument for Payments.create_net_banking_payment")
      end
    end
    parameters.each do |key, _|
      unless Array[:order_id, :merchant_id, :payment_method_type, :payment_method, :redirect_after_payment, :format].include?(key)
        puts " #{key} is an invalid argument for Payments.create_net_banking_payment"
      end
    end

    response = api_request(method,url,parameters)
    payment = Transaction.new(response.body)
    return payment
  end

  def Payments.create_wallet_payment(options={})
    method = 'POST'
    url = '/txns'
    parameters = {
      :payment_method_type => "WALLET",
      :format => 'json'
    }
    required_args = {}
    Array[:order_id, :merchant_id, :payment_method, :redirect_after_payment].each do |key|
      required_args.store(key,'False')
    end
    options.each do |key, value|
      parameters.store(key,value)
      required_args[key] = 'True'
    end
    Array[:order_id, :merchant_id, :payment_method, :redirect_after_payment].each do |key|
      if required_args[key] == 'False'
        raise InvalidArguementError.new("ERROR: #{key} is a required argument for Payments.create_wallet_payment")
      end
    end
    parameters.each do |key, _|
      unless Array[:order_id, :merchant_id, :payment_method_type, :payment_method, :redirect_after_payment, :format, :direct_wallet_token].include?(key)
        puts " #{key} is an invalid argument for Payments.create_wallet_payment"
      end
    end

    response = api_request(method,url,parameters)
    payment = Transaction.new(response.body)
    return payment
  end

  def Payments.get_payment_methods(options={})
    merchant = get_arg(options, :merchant_id)

    if merchant == NIL
      raise InvalidArguementError.new("ERROR: `merchant_id` is required parameter for Payments.get_payment_methods()")
    end

    url = "/merchants/#{merchant}/paymentmethods"

    method = 'GET'
    response = Array(api_request(method,url,{}).body['payment_methods'])
    payment_methods = []
    i=0
    while i != response.count
      payment_method = PaymentMethod.new(response[i])
      payment_methods.push(payment_method)
      i+=1
    end
    return payment_methods
  end

end
