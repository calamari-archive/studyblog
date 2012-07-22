class Mailing < ActiveRecord::Base
  belongs_to :study
  has_one :moderator, :through => :study
  belongs_to :owner, :class_name => 'User'

  before_save :check_text

  attr_accessible :text

  def is_saved?
    !!self.name
  end

  def self.all_of_owner(owner)
    Mailing.where(:owner_id => owner.id)
  end

  protected

  def check_text
    self.text = Sanitize.clean self.text, StudyBlog::Application.config.Sanitize[:mailing]
  end
end
