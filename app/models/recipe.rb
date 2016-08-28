class Recipe < ApplicationRecord

  scope :like, -> (keyword) { where("name like ? or description like ?", "%#{keyword}%", "%#{keyword}%") }
  scope :sh, -> { order('updated_at ASC') }
  
  def materials
    Material.where(recipe_id: self.id)
  end
  def steps
    Step.where(recipe_id: self.id)
  end
end
