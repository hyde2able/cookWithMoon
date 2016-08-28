class CreateRecipes < ActiveRecord::Migration[5.0]
  def change
    create_table :recipes do |t|
      t.string :image
      t.string :name
      t.string :rid
      t.string :description
      t.string :fee
      t.integer :fee_int
      t.string :time
      t.integer :time_int
      t.string :portion
      t.integer :portion_int
      t.binary :main

      t.timestamps
    end
  end
end
