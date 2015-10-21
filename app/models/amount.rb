class Amount

  attr_reader :amount, :symbol, :prefix

  NICE_DECIMALS = {usd: 2, eur: 2, cny: 2, silver: 2, gold: 4, btc: 4, bts: 0}

  def self.asset id
    @asset = {} unless @asset
    @asset[id] ||= Graphene::API::RPC.instance.get_asset(id)
  end

  def self.cent c
    Amount.new(c / 100.0, 'USD')
  end

  def self.from_bts arr
    a = asset(arr['asset_id'])
    Amount.new(arr['amount'].to_f / 10**a['precision'], a['symbol'])
  end

  # Amount.new(1.99, "USD")
  def initialize human_amount, symbol
    @amount = human_amount
    @symbol = symbol
    @prefix = (symbol == 'BTS' ? '' : 'Bit')
  end

  # Convert nicely e.g. 1.99 USD --> 12.99 CNY
  def convert to_symbol
    return self if to_symbol == @symbol
    to_amount = @amount * Asset.rate(@symbol, to_symbol)
    nicely_round Amount.new(to_amount, to_symbol)
  end

  # Add another amount e.g. 0.49 + 0.49 --> 0.98
  def add new_amount
    raise "Symbol mismatch" unless @symbol == new_amount.symbol
    dec = NICE_DECIMALS[@symbol.downcase.to_sym]
    Amount.new(BigDecimal.new(@amount, dec) + BigDecimal.new(new_amount.amount, dec), @symbol)
  end

  # Does this amount COVER the other?
  def includes? amt
    return nil if symbol != amt.symbol
    @amount >= amt.amount
  end



  def short
    "#{unit} #{@symbol}"
  end
  
  def full
    "#{unit} #{@prefix}#{@symbol}"
  end

  def unit
    s = @amount.to_s.sub(/\.0+$/, '')
    case @symbol
      when 'USD'    then "$%s"
      when 'CNY'    then "¥%s"
      when 'JPY'    then "¥%s"
      when 'EUR'    then "€%s"
      when 'GOLD'   then "%soz"
      when 'SILVER' then "%soz"
      else               "%s"
    end % s
  end

  def bts_asset_id
    Amount.asset(@symbol)['symbol']
  end

  def bts_amount
    (@amount.to_f * 10**Amount.asset(@symbol)['precision']).to_i
  end




private

  def nicely_round amount
    dec = NICE_DECIMALS[amount.symbol.downcase.to_sym]
    raise("Don't know precision for #{asset}") unless dec

    # Truncate the amount, e.g.  $1.001 -> $1.01
    num = BigDecimal.new(amount.amount.to_s).ceil(dec)

    # Round the number to certain thresholds
    nice_num = case
      when num == 0 then "0"
      when num < 0.005   then ("%0.04f" % num).gsub(/0+$/, '')
      when num < 0.05    then ("%0.03f" % num).gsub(/0+$/, '')
      when num < 0.25     then "%0.02f" % num
      when num < 0.4      then "%0.02f" % round(num, 0.05, 0.01)
      when num < 2        then "%0.02f" % round(num, 0.10, 0.01)
      when num <20&&dec>1 then "%0.02f" % round(num, 0.50, 0.01)
      when num < 20       then "%d"     % round(num, 1, 0)
      when num < 75       then "%d"     % round(num, 5, 1)
      when num < 500      then "%d"     % round(num, 10, 1)
      when num < 5000     then "%d"     % round(num, 100, 1)
      when num < 50000    then "%d"     % round(num, 1000, 1)
      when num < 500000   then "%d"     % round(num, 10000, 1)
      when num < 5000000  then "%d"     % round(num, 100000, 1)
      else                     "%d"     % round(num, 1000000, 1)
    end

    Amount.new(nice_num, amount.symbol)
  end

  # 0.13, 0.20, 0.01   -->  0.19
  # 4.13, 0.50,    0        4.50
  #   87,    5,    1        89
  #  213,   50,    0        250
  def round amount, precision, notch = 0
    (amount / precision).ceil * precision - notch
  end
end
