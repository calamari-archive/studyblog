class ConversationsController < ApplicationController
  def new
    @conversation = Conversation.between(current_user, params[:user_id]) if params[:user_id]
    prepare_new_and_reply
  end

  def reply
    @conversation = Conversation.find(params[:id])
    prepare_new_and_reply
    render :action => "new"
  end

  def update
    @conversation = Conversation.find(params[:id])
    handle_update_and_create(params[:conversation][:content])
  end

  def create
    @conversation = Conversation.between(current_user, params[:conversation][:recipient_id])
    if @conversation.save
      handle_update_and_create(params[:conversation][:content])
    else
      render :action => "new", :alert => t('conversations.messages.save_error')
    end
  end

private
  def recipient_of_conversation(conversation)
    conversation.usera == current_user ? conversation.userb : conversation.usera
  end

  def handle_update_and_create(content)
    @conversation.messages.create(:content => content, :author => current_user)
    @message = @conversation.messages.last
    @recipient = recipient_of_conversation(@conversation)
    if @message.save
      redirect_to user_path(@recipient), :notice => t('conversations.messages.successful', :name => @recipient.name)
    else
      @messages = @conversation.messages
      render :action => "new", :alert => t('conversations.messages.save_error')
    end
  end

  def prepare_new_and_reply
    @conversation.messages << Message.new
    @message = @conversation.messages.last
    @recipient = recipient_of_conversation(@conversation)
    @messages = @conversation.messages
  end
end
