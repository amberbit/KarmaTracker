KarmaTracker::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resource :user do
        get :confirm
      end

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
          post :git_hub_activity_web_hook
          get :recent
        end
        member do
          get :tasks
          get :current_tasks
          get :pivotal_tracker_activity_web_hook_url
          post :pivotal_tracker_activity_web_hook
        end
      end
      resources :tasks, only: [:index, :show] do
        collection do
          get :running
          get :recent
        end
      end
    end
  end

  match '/404' => 'errors#not_found'
  match '/500' => 'errors#exception'

  root to: 'home#index'
end
