class AddGroupToUsers < ActiveRecord::Migration
  def self.up
    add_index :users, :group_id, :integer
  end

  def self.down
    remove_column :users, :group_id
  end
end
