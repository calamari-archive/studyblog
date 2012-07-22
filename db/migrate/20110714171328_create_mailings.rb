class CreateMailings < ActiveRecord::Migration
  def self.up
    create_table :mailings do |t|
      t.text :text
      t.integer :study_id

      t.timestamps
    end
  end

  def self.down
    drop_table :mailings
  end
end
