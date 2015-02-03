class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer  :product_id
      t.integer  :shipping_id
      t.string   :address
      t.integer  :cents
      t.datetime :paid_at
      t.string   :trx_id
      t.datetime :due_at
      t.string   :comments
      t.string   :pub_id
      t.boolean  :void, :null => false, :default => false

      t.timestamps
    end
  end
end
