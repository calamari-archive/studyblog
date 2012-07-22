class CreatePrivateMessages < ActiveRecord::Migration
  def self.up
    create_table :private_messages do |t|
      t.string :subject
      t.text :text
      t.integer :author_id
      t.integer :recipient_id
      t.boolean :read, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :private_messages
  end
end
