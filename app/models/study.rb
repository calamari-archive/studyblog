require 'digest'

# validates is time is before or after another time
class TimingValidator < ActiveModel::EachValidator
  def initialize(options)
    @before = options[:before] || nil
    @after = options[:after] || nil
    super
  end

  def validate_each(record, attribute, value)
    if !value.nil?
      compare_value = (@after.class == Time ? @after : (record[@after].nil? ? false : record[@after]))
      if !@after.nil? && compare_value && compare_value > value
        record.errors.add attribute, I18n.t('activerecord.errors.messages.after', :attribute => attribute, :time => I18n.l(@after))
      end
      compare_value = (@before.class == Time ? @before : (record[@before].nil? ? false : record[@before]))
      if !@before.nil? && compare_value && compare_value < value
        record.errors.add attribute, I18n.t('activerecord.errors.messages.before', :attribute => attribute, :time => I18n.l(@before))
      end
    end
  end
end


class Study < ActiveRecord::Base
  has_many :groups, :dependent => :destroy
  has_many :participants, :class_name => 'User', :through => :groups
  belongs_to :moderator, :class_name => 'User'
  has_one :mailing

  with_options :unless => :deleted do |study|
    study.validates_presence_of :title, :start_date, :end_date

    study.validates :end_date, :timing => { :after => :start_date }
  end
  validates :start_date, :timing => { :after => Time.now }, :if => :validate_start_date_check

  attr_accessible :title, :description, :start_date, :end_date

  def activate
    if self.is_activatable?
      self.participants.each do |p|
        p.active = true

        # TODO: reassign password and mail it
        p.password =  Digest::SHA1.hexdigest("some-random-string")[0..5]
        p.password_confirmation = p.password

        # send mails out to the users
        if self.mailing
          p.save
          UserMailer.new_participant_from_mailing(p, self.mailing).deliver
        else
          UserMailer.new_participant(p).deliver
        end
      end

      self.groups.each do |group|
        group.create_groupblog if group.has_groupblog
      end

      #TODO: write test that activate works with saving users!!!
      self.activated = true
    end
    self.activated
  end

  def spectators
    self.groups.map {|group| group.spectators }.flatten
  end

  def is_activatable?
    !self.is_activated? && self.count_participants > 0 && self.start_date && self.start_date > Time.now ? true : false
  end

  def count_participants # that is cheating but hey, it works
    self.groups.map { |g| g.participants.length; }.sum
  end

  def is_activated?
    self.activated
  end

  def has_started?
    is_activated? && self.start_date < Time.now
  end

  def has_ended?
    is_activated? && self.end_date < Time.now
  end

  def is_running?
    now = Time.now
    is_activated? && self.start_date && self.end_date && self.start_date < now && now < self.end_date
  end

  def is_deleted?
    self.deleted
  end

  def start_day=(date)
    self.start_date = date.beginning_of_day
  end

  def start_day
    self.start_date
  end

  def end_day=(date)
    self.end_date = date.end_of_day
  end

  def end_day
    self.end_date
  end

  def duration
    ((self.end_date - self.start_date) / 3600 / 24).round if self.start_date && self.end_date
  end

  def self.count_deleted
    Study.where(:deleted => true).count
  end

  def belongs_to?(user)
    self.moderator == user
  end

  def mailing_defined?
    !!self.mailing
  end

  def self.all_of_moderator(user)
    self.where(:moderator_id => user, :deleted => false)
  end

  protected

  def validate_start_date_check
    self.activated && !self.deleted
  end
end
