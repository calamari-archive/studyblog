class AddRoleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :role, :string, :limit => 12, :default => 'participant'
  end

  def self.down
    remove_column :users, :role
  end
end
