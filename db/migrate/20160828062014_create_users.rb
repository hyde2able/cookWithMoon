class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :rid
      t.boolean :cook
      t.string :mid
      t.string :name
      t.integer :now_step
      t.integer :max_step

      t.timestamps
    end
  end
end
