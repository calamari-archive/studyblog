class ConversationsController < ApplicationController
  def new
    @conversation = Conversation.between(current_user, params[:user_id]) if params[:user_id]
    @conversation.messages << Message.new
    @message = @conversation.messages.last
    @recipient = recipient_of_conversation(@conversation)
  end

  def update
    @conversation = Conversation.find(params[:id])
    handle_new_message_to_conversation(params[:conversation][:content])
  end

  def create
    @conversation = Conversation.between(current_user, params[:conversation][:recipient_id])
    if @conversation.save
      handle_new_message_to_conversation(params[:conversation][:content])
    else
      render :action => "new", :alert => t('conversations.messages.save_error')
    end
  end

private
  def recipient_of_conversation(conversation)
    conversation.usera == current_user ? conversation.userb : conversation.usera
  end

  def new_message_to_conversation(content)
    @conversation.messages.create(:content => content, :author => current_user)
    @message = @conversation.messages.last
    @recipient = recipient_of_conversation(@conversation)
    @message.save
  end

  def handle_new_message_to_conversation(content)
    if new_message_to_conversation(content)
      redirect_to user_path(@recipient), :notice => t('conversations.messages.successful', :name => @recipient.name)
    else
      render :action => "new", :alert => t('conversations.messages.save_error')
    end
  end
end
