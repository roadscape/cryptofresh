class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.text    :desc
      t.integer :position
      t.integer :default_id
      t.boolean :is_category, :null => false, :default => false

      t.integer :parent_id    
      t.integer :cents

      t.attachment :dl
      t.attachment :image
      t.timestamps
    end

  end
end
