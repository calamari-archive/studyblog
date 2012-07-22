class AddStartpageToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :startpage, :text
  end

  def self.down
    remove_column :groups, :startpage
  end
end
