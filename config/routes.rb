Rails.application.routes.draw do
  get 'techgit/s'

  post '/callback', to: 'webhook#callback'
  get '/search/:keyword', to: 'webhook#search'
  get '/images/:rid/:size', to: 'webhook#image'
  get '/assets/:path/:size', to: 'webhook#assets'
  get '/tech-img/:tech/:id/:size', to: 'webhook#tech'

  # recipe
  get '/recipe/:rid', to: 'recipes#show'
  get '/recipe/:rid/materials', to: 'materials#index'
  get '/recipe/:rid/share', to: 'recipes#share'

  # tech
  get '/tech/:tech/:id', to: 'techs#show'
  get '/techs', to: 'techs#index'
end
