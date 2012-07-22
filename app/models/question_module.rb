class QuestionModule < ActiveRecord::Base
  TYPES = ['free_text', 'likert']
  has_one :topic, :as => :module
  has_many :answers, :class_name => QuestionModuleAnswer

  validates_presence_of :question_type
  validates_inclusion_of :question_type, :in => TYPES

  validate :check_possible_answers_format
  validate :check_config_format

  before_save :save_config
  after_save :load_config
  after_find :load_config
  after_initialize :init_config

  attr_accessible :question_type, :number_steps, :left_extreme, :right_extreme, :possible_answers

  def number_steps
    self.config['steps'].to_i || 0
  end

  def number_steps=(val)
    self.set_config_value 'steps', val
  end

  def left_extreme
    self.config['left_extreme'] || ""
  end

  def left_extreme=(val)
    self.set_config_value 'left_extreme', val
  end

  def right_extreme
    self.config['right_extreme'] || ""
  end

  def right_extreme=(val)
    self.set_config_value 'right_extreme', val
  end

  def possible_answers
    self.read_attribute(:possible_answers).gsub(/\r/, '').split("\n")
  end

  # TODO: this has to be in an parent class, but then we have to think about other stuff too
  def permitted_to_read?(user)
    !user.is_participant? || answers.joins(:blog_entry).where('author_id = ?', user.id).count > 0
  end

  def permitted_to_write?(user)
    user.is_participant? && topic.group_id == user.group_id
  end

  protected

  def set_config_value(key, val)
    self.config = {} unless self.config
    self.config[key] = val
  end

  def check_possible_answers_format
    # free_text needs no list of possible answers
    return if self.question_type == 'free_text'

    if self.question_type == 'likert'
      errors[:possible_answers] << I18n.t('modules.question.errors.likert.possible_answers') if self.possible_answers == ''
    end
  end

  def check_config_format
    # free_text needs no config
    return if self.question_type == 'free_text'

    # if config is not set, its not right
    unless self.config
      errors[:config] << I18n.t('modules.question.errors.steps')
      return
    end

    # likert needs steps to be between 2 and 10
    if self.question_type == 'likert'
      errors[:config] << I18n.t('modules.question.errors.likert.steps') if (!self.config['steps'] || self.config['steps'].to_i < 2 || self.config['steps'].to_i > 10)
      if !self.config['left_extreme'] || self.config['left_extreme'] == ''
        errors[:left_extreme] << I18n.t('modules.question.errors.likert.extremes')
      elsif !self.config['right_extreme'] || self.config['right_extreme'] == ''
        errors[:right_extreme] << I18n.t('modules.question.errors.likert.extremes')
      end
    end
  end

  def save_config
    self.config = self.config.to_json
  end

  def load_config
    self.config = ActiveSupport::JSON.decode(self.config) || {}
  end

  def init_config
    self.config ||= {}
  end
end
