module PrivateMessagesHelper
  def number_unread_messages
    return 0 unless current_user
    PrivateMessage.where({ :recipient_id => current_user.id, :read => false }).count
  end
end
