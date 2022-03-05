Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/ask_question', to: 'question_answer_pair#create'
      get '/see_qas', to: 'question_answer_pair#show'
    end
  end
  root 'application#index'
end
