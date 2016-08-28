class MaterialsController < ApplicationController
  def index
    @recipe = Recipe.find_by(rid: params[:rid])
    @materials = @recipe.materials

    render layout: false
  end
end
