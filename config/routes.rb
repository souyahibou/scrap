Rails.application.routes.draw do
  get 'scrapping/home'
  root 'scrapping#home'
  get 'scrapping/search'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
