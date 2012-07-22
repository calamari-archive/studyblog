class StartpageController < ApplicationController
  filter_access_to :all
  skip_filter :check_if_participant_and_study_has_ended, :only => :ended

  def index
    if !current_user
      redirect_to login_url
      return
    end

    if current_user.is_participant?
      if current_user.is_not_setup?
        redirect_to setup_user_url
      else
        participant_index
        render :action => :participant_index
      end
    end

    if current_user.is_spectator?
      spectator_index
      render :action => :spectator_index
    end
  end

  def participant_index
    @user  = current_user
    @study = @user.study
    @group = @user.group
    @blog  = @user.has_blog? ? @user.blog : @group.groupblog
  end

  def spectator_index
    @user  = current_user
    @study = @user.study
  end

  def ended
    @user  = current_user
    @study = @user.study
    redirect_to root_url if @study.is_running?
  end
end
