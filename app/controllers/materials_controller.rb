class MaterialsController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    @recipe = Recipe.find_by(rid: params[:rid])
    @materials = @recipe.materials

    render layout: false
  end
end
