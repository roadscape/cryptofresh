class CreateShippings < ActiveRecord::Migration
  def change
    create_table :shippings do |t|
      t.string  :name
      t.integer :cents
      t.timestamps
    end
    Shipping.create(:name => 'United States', :cents =>  575)
    Shipping.create(:name => 'International', :cents =>  900)
    Shipping.create(:name => 'Mexico/Canada', :cents =>  700)
  end
end
