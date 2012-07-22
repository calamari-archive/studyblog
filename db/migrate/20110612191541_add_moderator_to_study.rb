class AddModeratorToStudy < ActiveRecord::Migration
  def self.up
    add_column :studies, :moderator_id, :integer
  end

  def self.down
    remove_column :studies, :moderator_id
  end
end
