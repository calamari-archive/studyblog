class AddActivatedToStudy < ActiveRecord::Migration
  def self.up
    add_column :studies, :activated, :boolean, :default => false
  end

  def self.down
    remove_column :studies, :activated
  end
end
