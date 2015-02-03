class Extras < ActiveRecord::Migration
  def change
    add_column :products, :code, :string
    add_column :products, :short_desc, :string
    add_column :products, :button_label, :string
    add_column :products, :num_stock, :integer
    add_column :products, :num_sold, :integer
    add_column :products, :node_type, :string
  end
end
