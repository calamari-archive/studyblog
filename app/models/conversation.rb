class Conversation < ActiveRecord::Base
  belongs_to :usera, :class_name => 'User'
  belongs_to :userb, :class_name => 'User'
  has_many :messages

  attr_accessible :read_by_a, :read_by_b, :usera_id, :userb_id, :usera, :userb, :subject

  validates_presence_of :usera_id, :userb_id, :subject

  scope :between, lambda {|a, b| where('(usera_id = :usera_id AND userb_id = :userb_id) OR (userb_id = :usera_id AND usera_id = :userb_id)', :usera_id => a.to_param, :userb_id => b.to_param) }
  scope :of, lambda {|user| where('usera_id = :user_id OR userb_id = :user_id', :user_id => user.to_param) }
  scope :unread, lambda {|user| where('(usera_id = :user_id AND read_by_a = false) OR (userb_id = :user_id AND read_by_b = false)', :user_id => user.to_param) }

  def read_by!(user)
    if usera_id == user.id
      self.read_by_a = true
    elsif userb_id == user.id
      self.read_by_b = true
    end
  end

  def unread_by!(user)
    if usera_id == user.id
      self.read_by_a = false
    elsif userb_id == user.id
      self.read_by_b = false
    end
  end

  def read_by?(user)
    if usera_id == user.id
      self.read_by_a
    elsif userb_id == user.id
      self.read_by_b
    else
      false
    end
  end

  def the_other_user(user)
    if usera.id == user.id
      userb
    else
      usera
    end
  end

  def has_written_something(user)
    messages.where(:author_id => user).count > 0
  end
end
