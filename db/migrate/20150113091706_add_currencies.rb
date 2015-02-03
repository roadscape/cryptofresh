class AddCurrencies < ActiveRecord::Migration
  def change
    add_column :orders, :bts_amount, :integer
    add_column :orders, :bts_asset_id,  :string
  end
end
