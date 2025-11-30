Rails.application.routes.draw do
  get 's3_test/index'
  post 's3_test/upload', to: 's3_test#upload', as: 's3_test_upload'
  get 's3_test/download', to: 's3_test#download', as: 's3_test_download'
  post 's3_test/delete', to: 's3_test#delete', as: 's3_test_delete'
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "s3_test#index"
end
