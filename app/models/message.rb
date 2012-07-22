class Message < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :conversation

  attr_accessible :author_id, :author, :content, :conversation_id

  validates_presence_of :author_id, :conversation_id, :content
end
