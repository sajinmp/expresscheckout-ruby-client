require_relative 'util'

class Customers

  # noinspection ALL
  class Customer

    attr_reader :id, :object, :date_created, :email_address, :first_name, :last_name, :mobile_country_code, :mobile_number, :object_reference_id

    def initialize(options = {})
      @id = get_arg(options, 'id')
      @object = get_arg(options, 'object')
      @date_created = get_arg(options, 'date_created')
      @last_update = get_arg(options, 'last_updated')
      @email_address = get_arg(options, 'email_address')
      @first_name = get_arg(options, 'first_name')
      @last_name = get_arg(options, 'last_name')
      @mobile_country_code = get_arg(options, 'mobile_country_code')
      @mobile_number = get_arg(options, 'mobile_number')
      @object_reference_id = get_arg(options, 'object_reference_id')
    end

  end

  def Customers.create(options={})
    if (options.length == 0)
      raise InvalidArguementError.new()
    end
    method = 'POST'
    url = '/customers'
    response = api_request(method,url,options)
    customers = Customer.new(response.body)
    return customers
  end

  def Customers.list(options={})
    method = 'GET'
    url = '/customers'
    offset = get_arg(options,:offset)
    count = get_arg(options,:count)

    if count == NIL and offset == NIL
          puts "count & offset can be passed if required.\n"
    end

    response = api_request(method,url,options).body
    customer_list = Array(response['list'])
    customers = []
    customer_list.each  do |customerData|
      customer = Customer.new(customerData)
      customers.push(customer)
    end
    customer_response = {
        'count' => response['count'],
        'offset' => response['offset'],
        'total' => response['total'],
        'list' => customers
    }
    return customer_response
  end

  def Customers.get(options={})
    customer_id = get_arg(options,:customer_id)
    if customer_id == NIL or customer_id == ''
      raise InvalidArguementError.new("ERROR: `customer_id` is a required parameter for Customers.get().")
    end

    method = 'GET'
    url = "/customers/#{customer_id}"
    response = api_request(method,url,options)
    customers = Customer.new(response.body)
    return customers
  end

  def Customers.update(options={})
    customer_id = get_arg(options,:customer_id)
    if customer_id == NIL or customer_id == ''
      raise InvalidArguementError.new("ERROR: `customer_id` is a required parameter for Customers.update().")
    end

    method = 'POST'
    url = "/customers/#{customer_id}"
    response = api_request(method,url,options)
    customers = Customer.new(response.body)
    return customers
  end

  def Customers.delete(options={})
    raise "ERROR: Not Implemented"
  end

end
