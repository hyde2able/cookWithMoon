class TechsController < ApplicationController
  def index
  end

  def show
    @tech = Tech.find_by(id: params[:id])
    render layout: false
  end
end