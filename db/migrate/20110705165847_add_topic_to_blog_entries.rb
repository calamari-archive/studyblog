class AddTopicToBlogEntries < ActiveRecord::Migration
  def self.up
    add_column :blog_entries, :topic_id, :integer
  end

  def self.down
    remove_column :blog_entries, :topic_id
  end
end
