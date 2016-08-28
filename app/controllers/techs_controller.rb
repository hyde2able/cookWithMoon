class TechsController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    @techs = Tech.all
    render layout: false
  end

  def show
    @tech = Tech.find_by(name: tech_name(params[:tech], params[:id]))
    render layout: false
  end

  private
  def tech_name t, id
    techs = {cut: ['薄切り', '千切り', '斜め切り', '小口切り', '乱切り', 'ザク切り', 'くし形切り', 'そぎ切り', '輪切り', '半月切り', 
      'いちょう切り', '拍子木切り', 'さいの目切り', '角切り', '短冊切り', '細切り', 'ささがき', 'みじん切り'], yaku: ['素焼き', '塩焼き', '照り焼き', 'つけ焼き', 'かば焼き']}
    techs[t.to_s][id.to_i-1]
  end
end