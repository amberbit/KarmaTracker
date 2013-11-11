KarmaTracker::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resource :user do
        get :confirm
      end

      resources :session, only: [:create] do
        collection do
          post :oauth_verify
        end
      end

      resource :password_reset, only: [:create, :update]

      resources :time_log_entries, only: [:index, :create, :update, :destroy] do
        collection do
          post :stop
        end
      end

      resources :integrations, only: [:index, :show, :destroy] do
        collection do
          post :pivotal_tracker
          post :git_hub
        end
      end

      resources :projects, only: [:index, :show] do
        collection do
          get :refresh
          get ':id/refresh_for_project' => 'projects#refresh_for_project'
          post :git_hub_activity_web_hook
          get :recent
          get :also_working
        end
        member do
          get :tasks
          get :current_tasks
          get :pivotal_tracker_activity_web_hook_url
          post :pivotal_tracker_activity_web_hook
          put :toggle_active
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
  match '/auth/:provider/callback' => 'api/v1/session#oauth', via: :get
  match '/auth/failure' => 'api/v1/session#failure', via: :get

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  root to: 'home#index'
end
