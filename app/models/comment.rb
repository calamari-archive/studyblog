class Comment < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :blog_entry
  has_one :blog, :through => :blog_entry

  validates_presence_of :author, :blog_entry, :text

  attr_accessible :text
end
