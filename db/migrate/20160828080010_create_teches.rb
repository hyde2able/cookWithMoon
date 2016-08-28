class CreateTeches < ActiveRecord::Migration[5.0]
  def change
    create_table :teches do |t|
      t.string :name
      t.string :image
      t.string :eexplanation
      t.integer :tech_type

      t.timestamps
    end
  end
end
