KarmaTracker::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do

      get '/user' => 'users#user'

      resources :session, only: [:create]

      resources :tasks, only: []

      resources :time_log_entries, only: [:create, :update, :destroy] do
        collection do
          get :stop
        end
      end

      resources :identities, only: [:index, :show, :destroy] do
        collection do
          post :pivotal_tracker
        end
      end
      resources :projects,   only: [:index, :show]
    end
  end

  match '/404' => 'errors#not_found'
  match '/500' => 'errors#exception'

end
