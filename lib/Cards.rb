require_relative 'util'

class Cards

  # noinspection ALL
  class Card

    attr_reader :fingerprint, :expired, :type, :deleted, :exp_month, :number, :exp_year, :name, :token, :brand, :isin, :reference, :nickname, :issuer

    def initialize(options = {})
      @name = get_arg(options, 'name_on_card')
      @exp_year = get_arg(options, 'card_exp_year')
      @reference = get_arg(options, 'card_reference')
      @exp_month = get_arg(options, 'card_exp_month')
      @expired = get_arg(options, 'expired')
      @fingerprint = get_arg(options, 'card_fingerprint')
      @isin = get_arg(options, 'card_isin')
      @type = get_arg(options, 'card_type')
      @issuer = get_arg(options, 'card_issuer')
      @brand = get_arg(options, 'card_brand')
      @token = get_arg(options, 'card_token')
      @nickname = get_arg(options, 'nickname')
      @number = get_arg(options, 'card_number')
      @deleted = get_arg(options, 'deleted')
    end

  end

  def Cards.create(options={})
    if (options.length == 0)
      raise InvalidArguementError.new()
    end

    method = 'POST'
    url = '/card/add'
    response = api_request(method,url,options)
    card = Card.new(response.body)
    return card
  end

  def Cards.list(options={})
    customer_id = get_arg(options,:customer_id)
    if customer_id == NIL or customer_id == ''
      raise InvalidArguementError.new("ERROR: `customer_id` is a required parameter for Cards.list().")
    end

    method = 'GET'
    url = '/card/list'
    response = Array(api_request(method,url,options).body['cards'])
    cards = []
    i=0
    while i != response.count
      card = Card.new(response[i])
      cards.push(card)
      i+=1
    end
    return cards
  end

  def Cards.delete(options={})
    card_token = get_arg(options,:card_token)
    if card_token == NIL or card_token == ''
      raise InvalidArguementError.new("ERROR: `card_token` is a required parameter for Card.delete().")
    end

    method = 'POST'
    url = '/card/delete'
    response = api_request(method,url,options)
    card = Card.new(response.body)
    return card
  end
end
