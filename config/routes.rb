Rails.application.routes.draw do
  # Definir root
  root 'maps#index'

  # Rotas para o controller Maps
  resources :maps, only: [:index] do
    collection do
      post :upload_kml
    end
  end
end