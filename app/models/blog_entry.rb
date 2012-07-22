require "sanitize"

class BlogEntry < ActiveRecord::Base
  belongs_to :blog
  has_one :group, :through => :blog
  has_one :study, :through => :group
  belongs_to :author, :class_name => 'User'
  belongs_to :topic
  has_many :comments
  belongs_to :module_answer, :polymorphic => true

  before_save :check_text

  validates_presence_of :author, :blog
  validates_presence_of :title, :text, :unless => :module_answer

  attr_accessible :blog, :title, :text

  protected

  def check_text
    self.text = Sanitize.clean self.text, StudyBlog::Application.config.Sanitize[:blog_entry]
  end
end
