Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "search_likes" => "search_likes#index"
  get "search_likes/results" => "search_likes#results"
end
