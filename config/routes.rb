Rails.application.routes.draw do
  get  'scrappings/search2'

  get  'scrappings/search'

  root 'scrappings#home'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
