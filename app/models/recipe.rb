#      t.string :image
#      t.string :name
#      t.string :rid
#      t.string :description
#      t.string :fee
#      t.integer :fee_int
#      t.string :time
#      t.integer :time_int
#      t.string :portion
#      t.integer :portion_int
#      t.binary :main

class Recipe < ApplicationRecord
  scope :like, -> (keyword) { where("name like ? or description like ?", "%#{keyword}%", "%#{keyword}%") }
  scope :sh, -> { order('updated_at ASC') }
  
  def materials
    Material.where(recipe_id: self.id)
  end
  def steps
    Step.where(recipe_id: self.id).desc(:turn)
  end
end
