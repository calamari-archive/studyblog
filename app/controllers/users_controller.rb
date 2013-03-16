require 'mail'

class UsersController < ApplicationController
  load_and_authorize_resource

  helper_method :is_me?

  def index
    @users = User.where(:role => ['admin', 'moderator']).all
  end

  def show
    @user = params[:id].present? ? User.find(params[:id]) : current_user
    # for getting group participant list
    @group = @user.group if @user.is_participant?

    unless @user.is_me?(current_user)
      @conversations = Conversation.between(current_user, @user)
    else
      @conversations = []
    end

    #spectators have no profile for participants
    redirect_to root_url if @user.is_spectator? && current_user.is_participant?
  end

  def profile
    @user = params[:id].present? ? User.find(params[:id]) : current_user
    authorize! :read, @user

    if @user.update_attributes(params[:user])
      respond_to do |format|
        format.html do
          if params[:user][:password] && !params[:user][:password].empty?
            flash[:notice] = I18n.t('participants.messages.password_changed')
          end
          redirect_to profile_path
          return
        end
        format.json do
          result = {}
          unless params[:user][:password] && !params[:user][:password].empty?
            result[:image] = @user.image.url
            result[:success] = I18n.t('participants.messages.image_changed')
          end
          render :json => result
          return
        end
      end
    else
      if params[:user][:password]
        # for getting group participant list
        @group = @user.group if @user.is_participant?

        unless @user.is_me?(current_user)
          @conversations = Conversation.between(current_user, @user)
        else
          @conversations = []
        end
        @password_send = true

        flash[:alert] = I18n.t('participants.messages.password_change_failed')
        render :show
      end
    end
  end


  def new
    @user = User.new
  end


  def new_spectator
    @study = Study.find(params[:study_id])
    return unless is_moderated_by_me?(@study)
    @user = User.new
  end

  def create_spectator
    @study = Study.find(params[:study_id])
    return unless is_moderated_by_me?(@study)
    @user = User.new(params[:user])
    @user.username = @user.email
    @user.role = 'spectator'
    # add user to one group to make a study connection
    @user.group = @study.groups.first

    # add dummy password (TODO: generate random password and mail them on study activation time)
    @user.password = ActiveSupport::SecureRandom.base64(6)
    @user.password_confirmation = @user.password


    if @user.valid?
      UserMailer.new_spectator(@user).deliver
      @user.save
      redirect_to study_url(@study), :notice => I18n.t('spectators.messages.created')
    else
      render :action => "new_spectator", :alert  => I18n.t('spectators.messages.creation_failed')
    end
  end

  def destroy_spectator
    @user = User.find(params[:id])

    if @user.destroy
      UserMailer.delete_spectator(@user).deliver
      flash[:notice] = I18n.t('spectators.messages.deleted', :name => @user.name)
    else
      flash[:error] = I18n.t('spectators.messages.deletion_failed')
    end

    redirect_to study_url(@user.study)
  end


  def new_participant
    @group = Group.find(params[:group_id])
    return if check_study_status(@group.study)
    return unless is_moderated_by_me?(@group.study)
    @user = User.new
  end

  def create_participant
    @group = Group.find(params[:user][:group_id])
    return if check_study_status(@group.study)
    return unless is_moderated_by_me?(@group.study)

    @user = User.new(params[:user])
    @user.username = @user.email

    # add dummy password, real password will be generated on study activation time
    @user.password = "password"
    @user.password_confirmation = "password"

    if @user.save
      redirect_to study_url(@group.study), :notice => I18n.t('participants.messages.created')
    else
      render :action => "new_participant", :alert  => I18n.t('participants.messages.creation_failed')
    end
  end

  def destroy_participant
    @user = User.find(params[:id])

    if @user.destroy
      flash[:notice] = I18n.t('participants.messages.deleted')
    else
      flash[:error] = I18n.t('participants.messages.deletion_failed')
    end

    redirect_to study_url(@user.study)
    #TODO: only users of not active studies -> User.rb
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      redirect_to(users_path, :notice => I18n.t('users.messages.created'))
    else
      render :action => "new", :error  => I18n.t('users.messages.creation_failed')
    end
  end

  # PUT /users/1
  def update
    @user = current_user

    if @user.update_attributes(params[:user])
      redirect_to(@user, :notice => 'User was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def deactivate
    @user = User.find(params[:id])
    authorize! :deactivate, @user
    @user.active = false

    if @user.save
      redirect_to users_path, :notice => I18n.t('users.messages.deactivated')
    else
      redirect_to users_path, :error  => I18n.t('users.messages.deactivation_failed')
    end
  end

  def reactivate
    @user = User.find(params[:id])
    authorize! :reactivate, @user
    @user.active = true

    if @user.save
      redirect_to users_path, :notice => I18n.t('users.messages.reactivated')
    else
      redirect_to users_path, :error  => I18n.t('users.messages.reactivation_failed')
    end
  end

  def setup
    @user = current_user

    redirect_to root_url if !@user.is_participant? || !@user.is_not_setup?

    if request.method == "POST"
      params[:user][:age] = (params[:user][:age] || 0).to_i
      # reset password
      @user.crypted_password = nil

      if @user.update_attributes(params[:user])
        # create a blog
        @user.create_blog if @user.has_blog?
        redirect_to root_url
      else
        flash[:alert] = I18n.t('users.messages.setup_failed')
      end
    end
  end

  # move to helper methods
  def is_me?(user)
    user.is_me? current_user
  end

  protected

    def check_study_status(study)
      #TODO: test this switch
      if study.is_activated?
        flash[:alert] = I18n.t('participants.messages.study_already_activated')
        redirect_to study_url(study)
        return true
      end
    end

    def is_moderated_by_me?(study)
      unless current_user.is_admin? || study.moderator == current_user
        flash[:alert] = I18n.t('participants.messages.not_your_study')
        redirect_to study_url(study)
        return false
      end
      true
    end
end
