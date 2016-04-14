require 'sidekiq/web'
require 'sidekiq-status/web'

Rails.application.routes.draw do
  root to: 'home#index'
  post '/requests', to: 'requests#create', as: 'request'
  # На случай, если Антон зайдет на огонек :)
  # Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  #   user == 'jetruby' && password == 'security'
  # end
  mount Sidekiq::Web => '/sidekiq' # default
end
