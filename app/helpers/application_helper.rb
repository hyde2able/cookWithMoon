module ApplicationHelper
  def tech_url name
    cut = ['薄切り', '千切り', '斜め切り', '小口切り', '乱切り', 'ザク切り', 'くし形切り', 'そぎ切り', '輪切り', '半月切り', 
      'いちょう切り', '拍子木切り', 'さいの目切り', '角切り', '短冊切り', '細切り', 'ささがき', 'みじん切り']
    yaku = ['素焼き', '塩焼き', '照り焼き', 'つけ焼き', 'かば焼き']

    if cut.index(name)
      "/tech/cut/#{cut.index(name) + 1}"
    elsif yaku.index(name)
      "/tech/yaku/#{yaku.index(name) + 1}"
    end
  end
end
