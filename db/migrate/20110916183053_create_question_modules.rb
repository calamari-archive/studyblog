class CreateQuestionModules < ActiveRecord::Migration
  def self.up
    create_table :question_modules do |t|
      t.text :possible_answers
      t.string :question_type

      t.timestamps
    end

    create_table :question_module_answers do |t|
      t.text :answers
      t.integer :question_module_id

      t.timestamps
    end

    change_table :blog_entries do |t|
      t.references :module_answer, :polymorphic => true
    end
  end

  def self.down
    drop_table :question_modules
    drop_table :question_module_answers

    change_table :topics do |t|
      t.remove :module
    end
    change_table :blog_entries do |t|
      t.remove_references :module_answer, :polymorphic => true
    end
  end
end
