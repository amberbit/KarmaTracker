KarmaTracker::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      namespace :admin do
        resources :users, only: [:index, :show, :create, :update, :destroy]
        resources :identities, only: [:index, :show, :update, :destroy] do
          collection do
            post :pivotal_tracker
          end
        end
      end

      get '/user' => 'users#user'
      resource :user, only: [:create, :update, :destroy]

      resources :session, only: [:create]

      resources :time_log_entries, only: [:index, :create, :update, :destroy] do
        collection do
          post :stop
        end
      end

      resources :identities, only: [:index, :show, :destroy] do
        collection do
          post :pivotal_tracker
          post :git_hub
        end
      end
      resources :projects, only: [:index, :show] do
        collection do
          get :refresh
          get '/refresh_for_identity/:id' => 'projects#refresh_for_identity'
        end
        member do
          get :tasks
          get :current_tasks
        end
      end
    end
  end

  match '/404' => 'errors#not_found'
  match '/500' => 'errors#exception'

  root to: 'home#index'
end
