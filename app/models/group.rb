class Group < ActiveRecord::Base
  belongs_to :study
  has_many :participants, :class_name => 'User', :dependent => :destroy, :conditions => { :role => 'participant' }
  has_many :spectators, :class_name => 'User', :dependent => :destroy, :conditions => { :role => 'spectator' }
  has_many :topics, :order => 'created_at asc'
#  has_one :actual_topic, :class_name => 'Topic', :order => 'created_at desc', :readonly => true
  has_one :moderator, :through => :study

  validates_presence_of :title
  validate :validate_group_attributes
  validates :title, :uniqueness => { :scope => :study_id }

  before_save :sanitize_text

  attr_accessible :title, :description, :has_groupblog, :has_singleblogs, :are_commentable, :can_user_see_eachother

  STARTPAGE_KEYS = [ 'studyname', 'date', 'time', 'name' ]

  def actual_topic
    self.topics.select {|t| !t.module}.last
  end

  def contains_user(user)
    self.participants.index user
  end

  def sanitize_text
    return unless self.startpage
    self.startpage = Sanitize.clean(self.startpage, StudyBlog::Application.config.Sanitize[:startpage])
  end

  def groupblog
    return Blog.where(:group_id => self.id, :user_id => nil).first if self.has_groupblog
  end

  #TODO: test me!
  def create_groupblog
    return if self.groupblog || !self.has_groupblog

    Blog.create :group => self
  end

  def self.startpage_variables
    self::STARTPAGE_KEYS.map {|key| { :key => I18n.t('groups.startpage.replacements.keys.' + key), :desc => I18n.t('groups.startpage.replacements.descriptions.' + key) } }
  end

  protected

  def validate_group_attributes
    errors[:group_attributes] << I18n.t('groups.errors.no_blogs_set') unless self.has_groupblog || self.has_singleblogs
  end
end
