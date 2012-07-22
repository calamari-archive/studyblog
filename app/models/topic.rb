class Topic < ActiveRecord::Base
  has_many :blog_entries
  belongs_to :group
  # not essentially correct, more correct would be an has_one and belongs to in the different places
  belongs_to :module, :polymorphic => true

  validates_presence_of :title
  # if module is set it must be valid
  validates_associated :module

  attr_accessible :title

  def blog_entries_of_blog(blog)
    blog_entries.select {|entry| entry.blog_id == blog.id }
  end

  def is_module?
    !!self.module
  end

  def module_type_short
    self.module_type.gsub('Module', '').underscore if self.module_type
  end
end
