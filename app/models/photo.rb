class Photo < ActiveRecord::Base
  has_attached_file :image, 
    :styles      => { :medium => "450x300>", :thumb => "100x100>" }, 
    :url         => "/system/:class/:attachment/:id_partition/:style_:hash.:extension",
    :hash_data   => ":class/:attachment/:id/:style",
    :hash_secret => "thisisabitsharesstore2"
   #:default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  belongs_to :product

  validates_presence_of :product

end
