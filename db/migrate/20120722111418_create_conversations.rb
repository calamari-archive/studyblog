class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :usera_id
      t.integer :userb_id
      t.boolean :read_by_a, :default => false
      t.boolean :read_by_b, :default => false

      t.timestamps
    end
  end
end
