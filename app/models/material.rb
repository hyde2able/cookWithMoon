class Material
  include Mongoid::Document
  field :recipe_id, type: Integer
  field :name, type: String
  field :quantity, type: String
  field :quantity_int, type: Integer
end
