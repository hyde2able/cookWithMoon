source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

gem 'faraday'
gem 'faraday_middleware'

# for Crawler
gem 'robotex'
gem 'nokogiri'
gem 'anemone'

# for LINE
gem 'line-bot-api'
gem "rmagick", '~> 2.13.1', :require => 'RMagick'


group :development, :test do
  gem 'byebug', platform: :mri
  gem 'sqlite3'
  gem 'better_errors'       # 開発中のエラー画面をリッチにする
  gem 'binding_of_caller'   # 開発中のエラー画面にさらに変数の値を表示する
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'pry'         # => irb上位互換インタプリタ
  gem 'pry-doc'     # => pry上からmethod等のソースコードを確認可能に．
  gem 'pry-coolline' # => pryの入力に対してハイライト
end

group :production do
  gem 'pg'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
