class AddDeletedToStudy < ActiveRecord::Migration
  def self.up
    add_column :studies, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :studies, :deleted
  end
end
