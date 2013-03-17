class Comment < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :blog_entry
  has_one :blog, :through => :blog_entry
  has_one :group, :through => :blog
  has_one :study, :through => :group

  validates_presence_of :author, :blog_entry, :text

  attr_accessible :text, :blog_entry_id
end
