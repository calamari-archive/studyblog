module ConversationsHelper
  def number_unread_conversations
    return 0 unless current_user
    Conversation.unread(current_user).count
  end
end
