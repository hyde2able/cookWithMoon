class TechsController < ApplicationController
  protect_from_forgery with: :null_session
  def index
  end

  def show
    @tech = Tech.find_by(id: params[:id])
    render layout: false
  end
end