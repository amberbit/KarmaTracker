KarmaTracker::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :users
      resources :identities, only: [:index, :show, :create, :destroy]
    end
  end

end
