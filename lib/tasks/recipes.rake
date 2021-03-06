require 'net/http'
require 'uri'
require 'json'

namespace :recipes do
  desc "レシピを登録する"
  task fetch: :environment do
    END_POINT = 'http://recipe.rakuten.co.jp/search/'
    url = END_POINT + ENV['key']
    url += '/' + ENV['p'] if ENV['p']
    url += '/?s=4&v=0&t=2'
    url = URI.encode(url)

    p url

    user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.63 Safari/537.36'
    charset = nil
    html = open(url, 'User-Agent' => user_agent) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    x = doc.xpath('//div[@class="contentsBox"]/div[@class="recipeBox02"]//li/div/a')
    x.each do |n|
      link = n.attr('href')
      id = link.match(/\/(\d+)\//)[1]
      image = n.xpath('//div[@class="recipeImg"]//img').attr('src').value.sub(/\?thub=\d+/, '')
      name = n.xpath('//div[@class="recipeImg"]//img').attr('alt').value
      p name
      recipe = Recipe.new
      recipe.image = image
      recipe.name = name
      recipe.rid = id
    end
  end

  desc "レシピを補完"
  task completion: :environment do
    puts "START"
    recipes = Recipe.all
    count = recipes.count
    
    recipes.each_with_index do |recipe, r_index|
      puts "#{(r_index+1) * 100/count}%"
      next if recipe.materials.count != 0 && recipe.steps.count != 0

      uri = URI.parse("https://evening-harbor-95566.herokuapp.com/#{recipe.rid}")
      json = Net::HTTP.get(uri)
      result = JSON.parse(json)
      r = result['recipe']

      begin
        Recipe.transaction do
          recipe.portion = r['membernum']
          recipe.time = r['time']
          if /(\d+?)分/ =~ recipe.time
            recipe.time_int = $1.to_i
          end
          recipe.fee = r['fee']
          if /(\d+?)円/ =~ recipe.fee
            recipe.fee_int = $1.to_i
          end
          recipe.description = r['explanation']

          r['material']['name'].count.times do |i|
            material = Material.new(name: r['material']['name'][i], quantity: r['material']['quantity'][i])
            if /(\d+?)/ =~ material.quantity
              material.quantity_int = $1.to_i
            end
            material.recipe_id = recipe.id
            material.save
          end

          r['process'].each_with_index do |pro, index|
            step = Step.new(image: pro['image'], content: pro['operation'], turn: index)
            step.recipe_id = recipe.id
            step.save
          end

          p recipe if recipe.save
        end
      rescue
        puts "#{recipe.id}を補完できませんでした。"
      end
    end
    puts "END"
  end
end
