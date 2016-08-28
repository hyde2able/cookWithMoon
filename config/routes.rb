Rails.application.routes.draw do
  post '/callback', to: 'webhook#callback'
  get '/search/:keyword', to: 'webhook#search'
  get '/images/:rid/:size', to: 'webhook#image'
  get '/assets/:path/:size', to: 'webhook#assets'
  get '/tech-img/:tech/:id/:size', to: 'webhook#tech'

  # recipe
  get '/recipe/:rid', to: 'recipes#show'
  get '/recipe/:rid/materials', to: 'materials#index'
  get '/tech/:tech/:id', to: 'recipes#tech'
  get '/recipe/:rid/share', to: 'recipes#share'
end
