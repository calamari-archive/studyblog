class Conversation < ActiveRecord::Base
  belongs_to :usera, :class_name => 'User'
  belongs_to :userb, :class_name => 'User'
  has_many :messages

  attr_accessible :read_by_a, :read_by_b, :usera_id, :userb_id

  validates_presence_of :usera_id, :userb_id

  scope :of, lambda {|user| where('usera_id = :user_id OR userb_id = :user_id', :user_id => user.to_param)}

  def self.between(a, b)
    conversation = self.where('(usera_id = :usera_id AND userb_id = :userb_id) OR (userb_id = :usera_id AND usera_id = :userb_id)', :usera_id => a.to_param, :userb_id => b.to_param).first
    conversation = Conversation.new :usera_id => a.to_param, :userb_id => b.to_param if conversation.nil?
    conversation
  end
end
