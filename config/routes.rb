# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
#get 'closing', :to => 'closing#index'
get 'closing/:project_id', :to => 'closing#index'
post 'closing_do/:project_id', :to => 'closing#change'
