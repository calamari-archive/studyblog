class PrivateMessagesController < ApplicationController
  filter_access_to :all

  def index
    @private_messages = PrivateMessage.where({ :recipient_id => current_user.id }).order('created_at desc').all
  end

  def show
    @private_message = PrivateMessage.find(params[:id])
    @private_message.read = true
    @private_message.save
  end

  def conversation
    @messages = PrivateMessage.conversation(current_user.id, params[:user_id])
    @messages.each do |message|
      if message.recipient == current_user
        message.read = true
        message.save
      end
    end
    @user = @messages.first.author
  end

  def reply
    @original_message = PrivateMessage.find(params[:private_message_id])
    @private_message = PrivateMessage.new
    @recipient = @original_message.author == current_user ? @original_message.recipient : @original_message.author

    @private_message.subject = t('private_messages.message_reply_prefix') + @original_message.subject

    @messages = []
    @messages = PrivateMessage.conversation(current_user.id, @recipient.id) unless @recipient.is_me?(current_user)

    render :action => :new
  end

  def new
    @private_message = PrivateMessage.new
    @recipient = User.find(params[:user_id]) if params[:user_id]

    @messages = []
    @messages = PrivateMessage.conversation(current_user.id, @recipient.id) unless @recipient.is_me?(current_user)

    unless @recipient
      @available_contacts = []
      if current_user.is_participant?
        @available_contacts = current_user.group.participants.map{|p| [p.name, p.id] }
        @available_contacts << [current_user.group.moderator.name, current_user.group.moderator.id]
      elsif current_user.is_moderator?
        Study.all_of_moderator(current_user).each do |study|
          @available_contacts = @available_contacts | study.participants.map{|p| [p.name + " (#{study.title};#{p.group.title})", p.id] } if study.is_running?
        end
      elsif current_user.is_spectator?
        @available_contacts << [current_user.group.moderator.name, current_user.group.moderator.id]
      end
    end
  end

  def create
    @private_message = PrivateMessage.new params[:private_message]
    @recipient = @private_message.recipient
    @private_message.author = current_user

    if @private_message.save
      redirect_to user_path(@recipient), :notice => t('private_messages.messages.successful', :name => @recipient.name)
    else
      render :action => "new"
    end
  end

  def destroy
    @private_message = PrivateMessage.find(params[:id])
    if @private_message.recipient == current_user
      @private_message.destroy
      redirect_to private_messages_url
    else
      redirect_to :back, :alert => t('private_messages.message.delete_not_your_own')
    end
  end
end
