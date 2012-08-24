class ConversationsController < ApplicationController
  filter_access_to :all, :attribute_check => true

  def index
    @conversations = Conversation.of(current_user).includes(:usera).includes(:userb)
  end

  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages
    @user = recipient_of_conversation(@conversation)
    @conversation.read_by!(current_user)
    @conversation.save
  end

  def new
    if params[:user_id]
      @userb = User.find(params[:user_id]);
      @conversation = Conversation.new(:usera => current_user, :userb_id => @userb.id)
    else
      @conversation = Conversation.new(:usera => current_user)
      @userb = nil
    end
    #@recipient = User.find(params[:user_id]) if params[:user_id]
    @available_contacts = current_user.get_available_recipients if @userb.nil?
    @message = Message.new
    show_new_and_reply
  end

  def reply
    @conversation = Conversation.find(params[:id])
    if request.method == "POST"
      @message = Message.new(:content => params[:conversation][:content], :author => current_user)
      @message.conversation = @conversation
      @conversation.unread_by!(@conversation.the_other_user(current_user))
      @conversation.save
      if @conversation.save && @message.save
        return redirect_to conversation_path(@conversation)
      end
    else
      @message = Message.new
    end
    show_new_and_reply
  end

  def post_reply
    @conversation = Conversation.find(params[:id])
  end

  def create
    @conversation = Conversation.new(
      :usera => current_user,
      :userb_id => params[:conversation][:userb_id],
      :subject => params[:conversation][:subject]
    )
    @message = Message.new(:content => params[:conversation][:content], :author => current_user)
    @conversation.transaction do
      @conversation.save!
      @message.conversation = @conversation
      @message.save!
      flash[:notice] = t('conversations.messages.successful', :name => @conversation.userb.name)
      return redirect_to user_path(@conversation.userb)
    end
  rescue Exception => e
    @recipient = recipient_of_conversation(@conversation)
    #@conversation.messages << @message
    @messages = @conversation.messages
    @available_contacts = current_user.get_available_recipients
    flash[:alert] = t('conversations.messages.save_error')
    render "new"
  end

private
  def recipient_of_conversation(conversation)
    conversation.usera == current_user ? conversation.userb : conversation.usera
  end

  def show_new_and_reply
    @recipient = recipient_of_conversation(@conversation)
    @messages = @conversation.messages
    render "new"
  end
end
