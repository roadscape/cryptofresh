class Product < ActiveRecord::Base

  has_attached_file :dl, 
    :styles      => {},
    :url         => "/system/:class/:attachment/:id_partition/:style_:hash.:extension",
    :hash_data   => ":class/:attachment/:id/:style",
    :hash_secret => STORE['secret_phrase']
  
  # .mobi = application/octet-stream
  validates_attachment :dl, content_type: { content_type: ["application/pdf", "image/jpeg", "application/octet-stream", "application/epub+zip"] }

  has_attached_file :image, 
    :styles      => { :medium => "300x300>", :thumb => "100x100>" }, 
    :url         => "/system/:class/:attachment/:id_partition/:style_:hash.:extension",
    :hash_data   => ":class/:attachment/:id/:style",
    :hash_secret => STORE['secret_phrase']
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  has_many :orders
  has_many :photos

  accepts_nested_attributes_for :photos, :reject_if => lambda { |t| t['image'].blank? }, :allow_destroy => true

  #self.inheritance_column = :node_type

  def num_sold
    orders.select{|o| o.paid?}.size
  end

  def num_locked
    orders.select{|o| !o.paid? && !o.expired?}.size
  end

  def num_left
    return 9999 unless num_stock
    (num_stock - num_sold)
  end

  def sold_out?
    return false unless num_stock
    num_left <= 0
  end

  def all_images
    #self_and_descendants.select{|p| p.image.exists?}.map{|p| p.image}
    out = []
    out << image if image.exists?
    out += photos.map(&:image)
    out
    photos.any? ? photos.map(&:image) : (image.exists? ? [image] : [])
  end

  def priced?
    !cents.nil?
  end

  def amount
    Amount.cent(cents) if cents
  end

  def new_order
    Order.new(:product_id => id)
  end

  def self.categories
    Product.where(:parent_id => nil).order(:position)
  end

  def root?
    parent_id.nil?
  end
  
  def root
    parent_id ? Product.find(parent_id) : self
  end

  def depth
    return 0 unless parent_id
    1 + Product.find(parent_id).depth
  end

  def children
    Product.where(:parent_id => id)
  end

  def self_and_descendants
    [self] + children.map{|c| c.self_and_descendants}.flatten
  end
end
