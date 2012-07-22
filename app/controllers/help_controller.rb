class HelpController < ApplicationController
  filter_access_to :all

  def index
    @private_message = PrivateMessage.new
    @recipient = User.where(:role => 'admin')[0]
  end

  def create_pm
    @private_message = PrivateMessage.new params[:private_message]
    @recipient = @private_message.recipient
    @private_message.author = current_user

    if @private_message.valid?
      @private_message.subject = "[HELP] " + @private_message.subject
      @private_message.save
      redirect_to help_path, :notice => t('help.messages.request_successful', :name => @recipient.name)
    else
      render :action => "index"
    end
  end

end
