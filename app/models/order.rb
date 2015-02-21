class Order < ActiveRecord::Base
  belongs_to :product
  belongs_to :shipping

  validates_presence_of :product_id, :bts_amount, :bts_asset_id
  validates_presence_of :shipping_id, :address, :unless => :is_dd?

  before_validation :add_total, :set_pub_id, :check_stock
  before_create :set_due_at

  def to_param
    pub_id
  end

  def self.from_param pub_id
    where(:pub_id => pub_id).order('id DESC').first or raise ActiveRecord::RecordNotFound.new("Couldn't find order #{pub_id}")
  end



  def is_dd?
    product.dl.exists?
  end

  def expired?
    !paid? && (due_at < DateTime.now)
  end

  def stale?
    paid? ? paid_at < 1.day.ago : expired?
  end

  def paid?
    !paid_at.nil?
  end

  def bts_url
     "bts:#{Wallet::ACCT}/transfer/amount/#{amount.amount}/memo/#{pub_id}/asset/#{amount.symbol}"
  end

  def amount
    Amount.from_bts({'amount' => bts_amount, 'asset_id' => bts_asset_id})
  end
  def amount=(amt)
    self.bts_amount   = amt.bts_amount
    self.bts_asset_id = amt.bts_asset_id
  end

 
 
  def set_due_at #before_create
    self.due_at = 15.minutes.from_now
  end

  def check_stock #before_validation
    errors.add(:product_id, "out of stock!") if product.sold_out?
  end

  def add_total #before_validation
    raise "No product selected" unless product
    raise "No asset selected" unless bts_asset_id
    amt = product.amount.convert(bts_asset_id)
    amt = amt.add(shipping.amount.convert(bts_asset_id)) if shipping
    self.amount = amt
  end

  def set_pub_id #before_validation
    return if pub_id 
    opts = %w{a x z t r k b e d q w e y u s p t 3 2 6 8}
    self.pub_id = (1..4).map{|i| opts.sample}.join.upcase
  end

end
