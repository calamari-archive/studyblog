class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :title
      t.text :description
      t.boolean :has_groupblog, :default => false
      t.boolean :has_singleblogs, :default => true
      t.boolean :are_commentable, :default => true
      t.boolean :can_user_see_eachother, :default => true
      t.integer :study_id

      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
