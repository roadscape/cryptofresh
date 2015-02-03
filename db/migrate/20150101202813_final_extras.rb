class FinalExtras < ActiveRecord::Migration
  def change
    add_column :orders,   :email,         :string
    add_column :orders,   :ip,            :string
    add_column :orders,   :referrer_acct, :string
    add_column :txes,     :order_id,      :integer
    add_column :txes,     :entries_json,  :text
    add_column :txes,     :comment,       :string
    
    add_column :products, :royalty_acct,  :string
    add_column :products, :royalty_cents, :integer
    add_column :products, :refer_cents,   :integer
  end
end
