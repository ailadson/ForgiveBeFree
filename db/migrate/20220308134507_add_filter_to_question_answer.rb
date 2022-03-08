class AddFilterToQuestionAnswer < ActiveRecord::Migration[6.1]
  def change
    add_column :question_answers, :filter, :string
  end
end
