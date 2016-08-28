class Recipe < ApplicationRecord
 
  def materials
    Material.where(recipe_id: self.id)
  end
  def steps
    Step.where(recipe_id: self.id)
  end
end
