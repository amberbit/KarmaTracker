KarmaTracker::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do

      get '/user' => 'users#user'

      resources :sessions, only: [:create]

      resources :tasks, only: [] do
        member do
          get :start
          get :stop
        end
      end

      resources :time_log_entries, only: [:create, :update, :destroy]

      resources :identities, only: [:index, :show, :destroy] do
        collection do
          post :pivotal_tracker
        end
      end
    end
  end

  match '/404' => 'errors#not_found'
  match '/500' => 'errors#exception'

end
