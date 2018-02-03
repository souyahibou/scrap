Rails.application.routes.draw do
  get 'scrappings/request_code'

  get 'scrappings/response_code'

  get 'scrappings/connect'

  get  'scrappings/search2'

  get  'scrappings/search'

  root 'scrappings#home'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
