class UserSessionsController < ApplicationController
  skip_filter :check_if_participant_and_study_has_ended

  # GET /user_sessions/new
  # GET /user_sessions/new.xml
  def new
    @user_session = UserSession.new
  end

  # POST /user_sessions
  # POST /user_sessions.xml
  def create
    @user_session = UserSession.new(params[:user_session])

    if @user_session.save
      redirect_to root_url
    else
      Rails.logger.info @user_session.errors.inspect
      flash[:alert] = I18n.t('login.error_message')
      render :action => "new"
    end
  end

  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.xml
  def destroy
    @user_session = UserSession.find
    @user_session.destroy

    redirect_to root_url
  end
end
