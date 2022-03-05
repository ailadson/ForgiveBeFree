class CreateQuestionAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :question_answers do |t|
      t.text :question, null: false
      t.text :answer, null: false

      t.timestamps
    end
  end
end
