class AddDurationToStudy < ActiveRecord::Migration
  def self.up
    add_column :studies, :start_date, :datetime
    add_column :studies, :end_date, :datetime
  end

  def self.down
    remove_column :studies, :end_date
    remove_column :studies, :start_date
  end
end
