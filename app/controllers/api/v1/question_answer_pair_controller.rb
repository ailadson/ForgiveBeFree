class Api::V1::QuestionAnswerPairController < ApplicationController
  def create
    question = params[:question]
    wom_chunk = params[:chunk]
    userId = params[:userId]
    result = Api::V1::QuestionAnswerPairHelper.ask_question(wom_chunk, question, userId)
    answer = result[:answer]
    filter = result[:filter]
    qa_pair = QuestionAnswer.new(question: question, answer: answer, filter: filter)
    qa_pair.save
    render json: qa_pair
  end

  def show
  end
end
