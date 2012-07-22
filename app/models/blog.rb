class Blog < ActiveRecord::Base
  has_many :entries, :class_name => 'BlogEntry'
  belongs_to :user
  belongs_to :group
  has_one :study, :through => :group
  has_many :topics, :class_name => 'Topic', :through => :group
#  has_one :moderator, :through => [:group, :stud]
  has_many :comments, :class_name => 'Comment', :through => :entries
  has_many :images

  attr_accessible :group

  # a groupblog has no user, only a group
  def is_groupblog?
    !self.user_id
  end

  def is_writable?
    self.study && self.study.is_running? ? true : false
  end

  def is_commentable?
    self.group.are_commentable
  end

  #TODO: test
  def entries_of_topic(topic)
    entries.select {|entry| entry.topic == topic }
  end

  def entries_without_topic
    entries.select {|entry| entry.topic == nil }
  end

  def permitted_to_write?(user)
    #that should be handled via authorization but permitted_to? didn't work
    self.is_writable? && (self.user == user || has_groupblog_permission?(user)) && self.permitted_to_read?(user)
  end

  # determines if the user is allowed to comment in that blog
  def permitted_to_comment?(user)
    self.is_writable? && self.is_commentable? && self.permitted_to_read?(user)
  end

  # determines it the user is allowed to see that blog
  def permitted_to_read?(user)
    user.is_admin? || (has_groupblog_permission?(user) || self.user == user || self.group.moderator == user || (self.group.can_user_see_eachother && group.participants.include?(user)))
  end

  def actual_topic
    self.group.actual_topic
  end

  def answered_topics
    self.entries.collect {|entry| entry.topic }.uniq.reject {|topic| topic.nil? }
  end

  def topic_with_id(id)
    self.topics.all.find {|topic| topic.id == id }
  end

  def open_topics
    #BUGGY?!?
    self.topics.select {|topic| !self.answered_topics.include?(topic) }
  end

  def open_modules
    self.topics.select {|topic| !self.answered_topics.include?(topic) && topic.is_module? }
  end

  def topic_sorted_entries
    entries
  end

  def is_own?(user)
    self.user == user
  end

  protected

  def has_groupblog_permission?(user)
    self.is_groupblog? && self.group == user.group
  end
end
