class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :email
      t.datetime :last_email_at

      t.timestamps
    end
  end
end
