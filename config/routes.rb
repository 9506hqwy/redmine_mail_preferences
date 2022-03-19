# frozen_string_literal: true

RedmineApp::Application.routes.draw do
  resources :projects do
    put '/mail_preferences', to: 'project_mail_preferences#update', format: false
  end
end
