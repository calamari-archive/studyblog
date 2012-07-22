class AddConfigToQuestionModule < ActiveRecord::Migration
  def self.up
    add_column :question_modules, :config, :text
  end

  def self.down
    remove_column :question_modules, :config
  end
end
