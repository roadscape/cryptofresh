class Tx < ActiveRecord::Base
  validates_presence_of     :block_num, :trx_id, :json
  validates_numericality_of :block_num
end
