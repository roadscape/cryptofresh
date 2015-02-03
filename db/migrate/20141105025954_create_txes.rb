class CreateTxes < ActiveRecord::Migration
  def change
    create_table :txes do |t|
      t.integer :block_num
      t.string  :trx_id
      t.text    :json
    end

    add_index :txes, :block_num
    add_index :txes, :trx_id, :unique => true 
  end
end
