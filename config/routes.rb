PeddieSoundfile::Application.routes.draw do

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]

  resources :courses do
    resources :assignments do
      resources :responses do
        resources :annotations
      end
    end
  end

  resources :enrollments
  resources :audio_files
  resources :users

  root 'welcome#index'

end
