KarmaTracker::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      namespace :admin do
        resources :users, only: [:index, :show, :create, :update, :destroy]
      end

      get '/user' => 'users#user'

      resources :session, only: [:create]

      resources :tasks, only: []

      resources :time_log_entries, only: [:index, :create, :update, :destroy] do
        collection do
          get :stop
        end
      end

      resources :identities, only: [:index, :show, :destroy] do
        collection do
          post :pivotal_tracker
        end
      end
      resources :projects, only: [:index, :show] do
        collection do
          get :refresh
          get '/refresh_for_identity/:id' => 'projects#refresh_for_identity'
        end
      end
    end
  end

  match '/404' => 'errors#not_found'
  match '/500' => 'errors#exception'

end
