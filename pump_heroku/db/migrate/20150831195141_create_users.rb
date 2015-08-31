class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :venmo_id
      t.decimal :mpg
      t.timestamps null: false
    end
  end
end
