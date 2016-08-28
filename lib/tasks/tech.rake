require 'net/http'
require 'uri'
require 'json'

namespace :tech do
  desc "レシピを登録する"
  task fetch: :environment do
    HOST = 'https://mighty-shelf-27620.herokuapp.com'

    techs = {cut: ['薄切り', '千切り', '斜め切り', '小口切り', '乱切り', 'ザク切り', 'くし形切り', 'そぎ切り', '輪切り', '半月切り', 
      'いちょう切り', '拍子木切り', 'さいの目切り', '角切り', '短冊切り', '細切り', 'ささがき', 'みじん切り'], yaku: ['素焼き', '塩焼き', '照り焼き', 'つけ焼き', 'かば焼き', '味噌焼き']}

    techs.each_with_index do |(key, value), t_index|
      value.each_with_index do |tech, i|
        url = HOST + '/' + key.to_s + '/' + (i+1).to_s
        uri = URI.parse(url)
        json = Net::HTTP.get(uri)
        result = JSON.parse(json)
        result = result[key.to_s]

        tech = Tech.new(tech_type: t_index, explanation: result['explanation'], image: result['image'], name: result['name'])
        if tech.save
          p tech.name
        end
        p url
      end
    end
  end
end
