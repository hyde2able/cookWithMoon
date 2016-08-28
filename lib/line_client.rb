require "faraday"
require "faraday_middleware"
require "json"
require "pp"
require 'line/bot'

class LineClient
  HOST = 'https://line2016.herokuapp.com'

  def initialize(client, message)
    @client = client
    @message = message
    @to_mid = message.from_mid
    @user = User.find_or_create_by(mid: @to_mid)
  end

  def reply
    case @message
    when Line::Bot::Receive::Operation
      case @message.content
      when Line::Bot::Operation::AddedAsFriend
        introduce_myself # in private
      end
    when Line::Bot::Receive::Message
      if @user.cooking?
        case @message.content
        when Line::Bot::Message::Text
          if /次へ\(手順(\d+)へ\)/ =~ @message.content[:text]
            next_step $1.to_i
          elsif /諦める/ =~ @message.content[:text]
            recipe = Recipe.find_by(rid: @user.rid)
            send_text """#{recipe.name}のクッキングを途中で終了したぜ􀄃􀇓Moon unamused􏿿
人間生きてりゃいろいろあるよな！􀂔
よくここまでがんばった􀁼切り替えて、次いこ次！􀁹
また話しかけてくれよな！􀂍✨"""
            end_cooking            
          elsif /(.+?)を諦めます/ =~ @message.content[:text]
            recipe = Recipe.find_by(name: $1)
            send_text """#{recipe.name}のクッキングを途中で終了したぜ􀄃􀇓Moon unamused􏿿
人間生きてりゃいろいろあるよな！􀂔
よくここまでがんばった􀁼切り替えて、次いこ次！􀁹
また話しかけてくれよな！􀂍✨"""
            end_cooking
          else
            send_giveup
          end
        when Line::Bot::Message::Sticker
          when_stamp # in private
        end
      else
        case @message.content
        when Line::Bot::Message::Text
          if /(.+?)をつくります！！！/ =~ @message.content[:text]
            send_text """承知のすけ！􀁸
よし！#{$1}を作るぞ！􀄃􀇐Moon satisfied􏿿
材料は揃ってるかい？􀄃􀇚Moon kiss􏿿
準備ができたら、準備OKボタンを押してくれ！􀂐"""
            send_ok $1
          elsif /(.+?)を作る準備ok/ =~ @message.content[:text]
            start_cooking($1)
            next_step 1
          elsif /おすすめ|オススメ|お腹|空いた|何か/ =~ @message.content[:text]
            recipes = Recipe.sh.limit(2)
            recipes.each_with_index do |recipe, index|
              if index == 0
                message = "#{recipe.name}つくらないかい？？􀂌"
              else
                message = "他に#{recipe.name}とかどうかな??􀂌"
              end
              message += "所要時間は#{recipe.time}" if recipe.time.present?
              if recipe.fee.present?
                message += "\n費用は#{recipe.fee}だぜ！􀂍"
              else
                message += "だぜ！􀂍\nすまんが、費用はわからない􀁼\n【レシピ】をタップしてみると、何かわかるかもしれないぞ！􀂎"
              end
              send_text message
              send_choice recipe
            end

            # 更新
            recipes.each do |r|
              r.touch
              r.save
            end
          else
            recipes = Recipe.like(@message.content[:text]).sh.limit(2)
            if recipes.count == 0
              when_nothing # in private
            else
              recipes.each_with_index do |recipe, index|
                if index == 0
                  message = "#{recipe.name}つくらないかい？？􀂌\n"
                else
                  message = "他に#{recipe.name}とかどうかな??􀂌\n"
                end
                message += "所要時間は#{recipe.time}" if recipe.time.present?
                if recipe.fee.present?
                  message += "\n費用は#{recipe.fee}だぜ！􀂍"
                else
                  message += "だぜ！􀂍\nすまんが、費用はわからない􀁼\n【レシピ】をタップしてみると、何かわかるかもしれないぞ！􀂎"
                end
                send_text message
                send_choice recipe
              end
              # 更新
              recipes.each do |r|
                r.touch
                r.save
              end
            end
          end
        when Line::Bot::Message::Sticker
          send_text 'okok'      
        end
      end
    end 
  end

  # テクニックを補完
  def support message
    cut = ['薄切り', '千切り', '斜め切り', '小口切り', '乱切り', 'ザク切り', 'くし形切り', 'そぎ切り', '輪切り', '半月切り', 
      'いちょう切り', '拍子木切り', 'さいの目切り', '角切り', '短冊切り', '細切り', 'ささがき', 'みじん切り']
    yaku = ['素焼き', '塩焼き', '照り焼き', 'つけ焼き', 'かば焼き']

    cut.each_with_index do |c, index|
      if message.include?(c)
        tech(c, "cut/#{index + 1}")
      end
    end
    yaku.each_with_index do |y, index|
      if message.include?(y)
        tech(y, "yaku/#{index + 1}")
      end
    end
  end

  def tech(name, path)
    @client.rich_message.set_action(
      TECH: {
        text: name.to_s,
        link_url: "#{HOST}/tech/#{path}",
        type: 'web'           
      }
    ).add_listener(
      action: 'TECH',
      x: 0,
      y: 0,
      width: 1020,
      height: 144
    ).send(
      to_mid: @to_mid,
      image_url: "#{HOST}/tech-img/#{path}",
      alt_text: name.to_s
    )
  end

  # 料理開始
  def start_cooking name
    @user.cook = true
    @recipe = Recipe.find_by(name: name)
    @user.rid = @recipe.rid
    @user.now_step = 0
    @user.max_step = @recipe.steps.count
    @user.save
  end

  # 次のステップへ
  def next_step num
    @recipe = Recipe.find_by(rid: @user.rid) 
    step = @recipe.steps[num - 1]

    send_step(step)
    if_next = @recipe.steps[num].present?
    @user.update(now_step: num)
    next_step_button if_next
  end

  # 料理終了
  def end_cooking
    @user.cook = false
    @user.now_step = nil
    @user.rid = nil
    @user.max_step = nil
    @user.save
  end

  def send_step step
    c = @client.multiple_message
    if step.image.present?
      c = c.add_image(
        image_url: step.image,
        preview_url: step.image
      )
    end
    c.add_text(
      text: "手順 #{step.turn + 1}/#{@user.max_step}\n#{step.content}"
    ).send(
      to_mid: @to_mid
    )
    support(step.content)
  end

  # 次のステップがあるかどうか
  def next_step_button if_next
    if if_next
      @client.rich_message.set_action(
        NEXT: {
          text: "次へ(手順#{@user.now_step+1}へ)",
          params_text: "次へ(手順#{@user.now_step+1}へ)",
          type: 'sendMessage'          
        }
      ).add_listener(
        action: 'NEXT',
        x: 0,
        y: 0,
        width: 1020,
        height: 144
      ).send(
        to_mid: @to_mid,
        image_url: "#{HOST}/assets/next",
        alt_text: "次へ(手順#{@user.now_step+1}へ)"
      )
    else
      recipe = Recipe.find_by(rid: @user.rid)
      send_text("""お！完成したぞ！！􀂓􀂓
大変だったな􀂔よくがんばったな􀂔
ぜひ作った料理🍳をみんなにシェアしようぜ！􀂍
また料理作りたくなったら俺に話しかけてくれよなっ􀁺""")
      @client.rich_message.set_action(
        SHARE: {
          text: 'シェアしよう',
          link_url: "#{HOST}/recipe/#{recipe.rid}/share",
          type: 'web'        
        }
      ).add_listener(
        action: 'SHARE',
        x: 0,
        y: 0,
        width: 1020,
        height: 144
      ).send(
        to_mid: @to_mid,
        image_url: "#{HOST}/assets/share",
        alt_text: 'シェアしよう'
      )
      end_cooking
    end  
  end

  def send_giveup
    recipe = Recipe.find_by(rid: @user.rid)
    @client.rich_message.set_action(
      GIVEUP: {
        text: 'あきらめる',
        params_text: "#{recipe.name}を諦めます",
        type: 'sendMessage'
      }
    ).add_listener(
      action: 'GIVEUP',
      x: 0,
      y: 0,
      width: 1020,
      height: 144
    ).send(
      to_mid: @to_mid,
      image_url: "#{HOST}/assets/giveup",
      alt_text: '諦める'
    )
  end

  def send_ok name
    @client.rich_message.set_action(
      OK: {
        text: '準備ok',
        params_text: "#{name}を作る準備ok",
        type: 'sendMessage'
      }
    ).add_listener(
      action: 'OK',
      x: 0,
      y: 0,
      width: 1020,
      height: 144
    ).send(
      to_mid: @to_mid,
      image_url: "#{HOST}/assets/ok",
      alt_text: '準備OK'
    )    
  end

  def send_choice recipe
    Rails.logger.info(recipe.inspect)
    @client.rich_message.set_action(
      FOOD: {
        text: '食材',
        link_url: "#{HOST}/recipe/#{recipe.rid}/materials",
        type: 'web'
      },
      RECIPE: {
        text: 'レシピ',
        link_url: "#{HOST}/recipe/#{recipe.rid}",
        type: 'web'
      },
      COOK: {
        text: "#{recipe.name}をつくります！！！",
        params_text: "#{recipe.name}をつくります！！！",
        type: 'sendMessage'
      }
    ).add_listener(
      action: 'FOOD',
      x: 0,
      y: 0,
      width: 340,
      height: 1020
    ).add_listener(
      action: 'RECIPE',
      x: 341,
      y: 0,
      width: 340,
      height: 1020
    ).add_listener(
      action: 'COOK',
      x: 681,
      y: 0,
      width: 340,
      height: 1020
    ).send(
      to_mid: @to_mid,
      image_url: "#{HOST}/images/#{recipe.rid}",
      alt_text: recipe.name
    )
  end

  private
  def introduce_myself
    @client.send_text(
      to_mid: @to_mid,
      text: """ムーンとお料理を友達登録してくれてありがとう􀁹
これから一緒に料理マスター🍳を目指そうぜ􀂌

まった！􀁽
料理マスター？􀂎無理だろっ􀂑なんて思っただろ？？

心配するな！􀄃􀇜Moon ok􏿿俺が一つ一つ丁寧に教えるからな！􀄃􀇑Moon cool􏿿✨

食べたい料理があるとき、僕に話しかけてくれ！􀄃􀇗Moon hehe􏿿
その料理の作り方をあなたのペースに合わせて教えるよ！􀄃􀇕Moon angel􏿿✨

食べたいものがないけど料理したいなー􀂌ってときは【オススメ】ってLINE してね􀂍
僕が君にとっておきのレシピを紹介するよ􀄃􀇡Moon attracted􏿿"""
    )
    @client.send_text(
      to_mid: @to_mid,
      text: 'さっそくだけど􀂌今日作りたい料理🍳は何か教えてほしいな􀄃􀇗Moon hehe􏿿'
    )
  end

  def send_text text 
    @client.send_text(
      to_mid: @to_mid,
      text: text
    )   
  end

  def when_nothing
    send_text '見つかりませんでした。'
  end

  def when_stamp
    texts = ["""料理中にスタンプ送るなんて余裕だな！􀂌
このステップが終わったら【次へ】をおしてくれっ！􀂏""",
      """お、どした？􀁻
もし途中で作るのをやめる場合は【諦める】とLINEしてくれ􀁼""",
      """スタンプ送るなんて、レシピになかったぜ？？􀄃􀇏Moon cry􏿿
集中しないと、料理を作り終わらないぞ！􀄃􀇓Moon unamused􏿿
がんばれ！􀁹""",
      """よし、ちょっと飽きたら、休憩しようか􀄃􀇗Moon hehe􏿿
なにも、すべてを完璧にする必要はないんだ􀁺ぼちぼちやっていこうぜ􀂍✨""",
      """がんばれ􀁹􀁹􀁹􀁹君ならできるぞ！！􀄃􀇡Moon attracted􏿿􀄃􀇡Moon attracted􏿿􀄃􀇡Moon attracted􏿿􀄃􀇡Moon attracted􏿿フレーー！􀄃􀇐Moon satisfied􏿿フレーー！􀄃􀇐Moon satisfied􏿿フレーー！􀄃􀇐Moon satisfied􏿿"""
    ]
    send_text texts[rand(texts.count)]
  end
end