Rails.application.routes.draw do
  get 'reference/show'

  resources :snp_files, except: [:show]
  get 'snp_files/:id' => "snp_files#show"
  get 'snp_files/:id/input' => "snp_files#show_input"
  get 'snp_files/:id/:marker' => "snp_files#get_mask"
  get 'snp_files/:id/:marker/fasta' => "snp_files#get_fasta"
  get 'snp_files/index'

  get 'snp_files/new'

  get 'snp_files/create'

  get 'snp_files/edit'

  get 'snp_files/update'

  get 'snp_files/destroy'

  get ':page' => 'markdown#show'

  root to: "snp_files#new"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
