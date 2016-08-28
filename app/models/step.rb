class Step
  include Mongoid::Document
  field :recipe_id, type: Integer
  field :image, type: String
  field :content, type: String
  field :turn, type: Integer
end
