class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :product_id
      t.integer :position
      t.string :label

      t.timestamps
    end

    add_attachment :photos, :image
  end
end
