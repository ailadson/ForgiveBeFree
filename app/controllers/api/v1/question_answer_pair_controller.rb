class Api::V1::QuestionAnswerPairController < ApplicationController
  def create
    question = params[:question]
    wom_chunk = params[:chunk]
    answer = Api::V1::QuestionAnswerPairHelper.ask_question(wom_chunk, question)
    qa_pair = QuestionAnswer.new(question: question, answer: answer)
    qa_pair.save
    render json: qa_pair
  end

  def show
  end
end
