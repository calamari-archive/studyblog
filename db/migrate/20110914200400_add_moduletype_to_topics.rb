class AddModuletypeToTopics < ActiveRecord::Migration
  def self.up
    change_table :topics do |t|
      t.references :module, :polymorphic => true
    end
  end

  def self.down
    change_table :topics do |t|
      t.remove_references :module, :polymorphic => true
    end
  end
end
