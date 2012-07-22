class PrivateMessage < ActiveRecord::Base
  belongs_to :author,    :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'
  validates_presence_of :subject, :text, :recipient, :author

  validate :validate_writing_rights

  attr_accessible :recipient_id, :subject, :text, :author_id

  scope :conversation, lambda { |a_user_id, b_user_id| where("(recipient_id = :usera AND author_id = :userb) OR (recipient_id = :userb AND author_id = :usera)", :usera => a_user_id.to_i, :userb => b_user_id.to_i) }

  protected

  def validate_writing_rights
    return unless self.author
    ok = true
    if self.author.is_participant?
      ok = false if self.recipient.is_participant? && !self.author.is_in_same_group_as(self.recipient)
      ok = false if self.recipient.is_moderator? && !self.author.is_moderated_by(self.recipient)
      ok = false if self.recipient.is_spectator?
    end

    if self.author.is_spectator?
      ok = false if self.recipient.is_participant? || self.recipient.is_spectator?
      ok = false if self.recipient.is_moderator? && !self.author.is_moderated_by(self.recipient)
    end
    errors[:writing_rights] << I18n.t('private_messages.errors.writing_rights') unless ok
  end
end
