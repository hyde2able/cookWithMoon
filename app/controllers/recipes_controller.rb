class RecipesController < ApplicationController
  protect_from_forgery with: :null_session
  def show
    @recipe = Recipe.find_by(rid: params[:rid])
    @steps = @recipe.steps
    render layout: false
  end

  def share
    @recipe = Recipe.find_by(rid: params[:rid])
    ua = request.env["HTTP_USER_AGENT"]
    if ua.include?('Mobile')
      render layout: false
    elsif ua.include?('Android')
      render html: "アンドロイドはシェアまで実装できませんでした..."
    else
      render layout: false
    end
  end
end
