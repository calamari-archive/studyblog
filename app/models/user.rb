class BlogAlreadyExistsError < StandardError
end

class User < ActiveRecord::Base
  ROLES = ['admin', 'moderator', 'spectator', 'participant']
  acts_as_authentic

  belongs_to :group
  has_one :study, :through => :group
  has_one :blog
  has_many :blog_entries, :class_name => 'BlogEntry', :through => :blog, :source => :entries
  has_many :blog_comments, :class_name => 'Comment', :foreign_key => :author_id

  has_attached_file :image,
                    :styles => { :original => '120x160>', :small => '30x30>', :medium => '60x60>' },
                    :url    => '/' + StudyBlog::Application.config.app_config['users']['image']['dir'] + '/:id-:style.:extension',
                    :path   => ":rails_root/public/" + StudyBlog::Application.config.app_config['users']['image']['dir'] + "/:id-:style.:extension"

  validates_attachment_size :image, :less_than => 200.kilobytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/gif', 'image/png'] #StudyBlog::Application.config.app_config['users']['image']['dir'].split
  attr_protected :image_file_name, :image_content_type, :image_size


  validates_presence_of :username, :email, :role
  validates_uniqueness_of :username, :email
  validates_inclusion_of :role, :in => ROLES

  validates_presence_of :group_id, :if => :is_groupbound?

  validates_uniqueness_of :nickname, :scope => :group_id, :case_sensitive => false, :if => lambda { blank? }

  validates_numericality_of :age, :greater_then => 0, :only_integer => true, :allow_nil => true
  validate :validate_setup

  def moderated_studies
    Study.find :all, :conditions => { :moderator_id => id }
  end

  def running_studies
    self.moderated_studies.select {|study| study.is_running? }
  end

  def finished_studies
    self.moderated_studies.select {|study| study.has_ended? }
  end

  def name
    self.nickname || self.username
  end

  def study #Why do I have to specify that?
    self.group && self.group.study
  end

  def create_blog
    raise BlogAlreadyExistsError.new if self.blog

    self.build_blog :group => self.group
    self.blog.save
  end

  # participants and spectators are never active if their study is not
  def active
    if self.study && (self.is_participant? || self.is_spectator?)
      self.study.is_activated? && (self.is_spectator? || !self.study.has_ended?)
    else
      read_attribute(:active)
    end
  end

  # Needed by declarative_authorization
  def role_symbols
    [ self.role.to_sym ]
  end

  def is_me?(user)
    self.username == user.username
  end

  def is_groupbound?
    is_spectator? || is_participant?
  end

  def is_participant?
    self.role == 'participant'
  end

  def is_spectator?
    self.role == 'spectator'
  end

  def is_admin?
    self.role == 'admin'
  end

  def is_moderator?
    self.role == 'moderator'
  end

  #TODO: test those two
  def has_blog?
    self.group && self.is_participant? ? self.group.has_singleblogs && self.blog : false
  end

  def has_groupblog?
    self.group && self.is_participant? ? self.group.has_groupblog : false
  end

  def has_image?
    !!self.image.updated_at
  end

  def deactivated
    !self.active
  end

  def is_setup?
    !self.is_not_setup?
  end

  def is_not_setup?
    self.is_participant? && !self.nickname
  end

  def is_in_same_group_as(user)
    self.group.contains_user user
  end

  def is_moderated_by(user)
    self.group.moderator == user
  end

  protected

  def validate_setup
    if self.is_not_setup? && self.active && !self.nickname || self.nickname == ''
      errors[:nickname] << I18n.t('activerecord.errors.models.user.attributes.nickname.blank')
    end
  end
end
