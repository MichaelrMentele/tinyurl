Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "html_slices/new_shortlink", to: "html_slices#new_shortlinks"
  get "html_slices/shortlinks", to: "html_slices#shortlinks"
end
