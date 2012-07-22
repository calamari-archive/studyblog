class AddNameAndUserToMailings < ActiveRecord::Migration
  def self.up
    add_column :mailings, :owner_id, :integer
    add_column :mailings, :name, :string
  end

  def self.down
    remove_column :mailings, :owner_id
    remove_column :mailings, :name
  end
end
