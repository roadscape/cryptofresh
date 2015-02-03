class Asset

  VALID = %w{USD GOLD SILVER CNY EUR BTS}

  def self.valid? sym
    VALID.include? sym
  end

  def initialize asset
    @asset = asset.to_s.upcase
    raise "Unknown asset: #{asset}" unless Asset.valid?(asset)
  end

  def self.rate from, to, amt = 1
    r = case
      when from == to    then 1.0
      when from == 'BTS' then feed(to)
      when to   == 'BTS' then 1 / feed(from)
      else feed(to) / feed(from)
    end
  end

private
  def self.feed asset
    if @last.nil? || @last < 5.seconds.ago
      @price = {}
      @last  = DateTime.now
    end
    @price[asset] ||= BitShares::API::Blockchain.median_feed_price asset rescue raise("Asset `#{asset}` ERROR")
  end

end
