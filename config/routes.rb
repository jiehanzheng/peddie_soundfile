PeddieSoundfile::Application.routes.draw do

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  post '/sessions/destroy'

  resources :audio_files
  resources :courses do
    resources :assignments do
      resources :responses do
        get 'score/edit', to: 'responses#edit_score'
        resources :annotations
      end
    end
  end

  # admin only
  resources :enrollments
  resources :users

  root 'welcome#index'

end
