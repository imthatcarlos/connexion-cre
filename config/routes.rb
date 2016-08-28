Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "job_project#index"

  get "shipment_summary", to: "shipment_summary#show"

  get "export_csv",       to: "export#csv"
  get "export_pdf",       to: "export#pdf"

  resources :cut_sheets, only: [:index, :create], path: 'cutsheets'
end
