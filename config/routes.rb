KarmaTracker::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do

      resources :users, only: [] do
        collection do
          get :me
          get :authenticate
        end
      end

      resources :tasks, only: [] do
        member do
          get :start
          get :stop
        end
      end

    end
  end

end
