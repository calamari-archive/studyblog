class StudiesController < ApplicationController
  before_filter :get_study, :only => [:assign, :activate]
  filter_access_to :all, :attribute_check => true

  def index
    if (current_user.is_admin?)
      @studies = Study.all
    else
      @studies = Study.all_of_moderator current_user
    end
  end

  def show
    @study = Study.find(params[:id])
  end

  def new
    @study = Study.new
  end

  def edit
    @study = Study.find(params[:id])
  end

  def create
    @study = Study.new(params[:study])
    @study.start_day = @study.start_date if @study.start_date
    @study.end_day = @study.end_date if @study.end_date

    @study.moderator = current_user

    if @study.save
      redirect_to(@study, :notice => t('studies.messages.created'))
    else
      render :action => "new"
    end
  end

  def update
    @study = Study.find(params[:id])

    if @study.update_attributes(params[:study])
      redirect_to(@study, :notice => t('studies.messages.created'))
    else
      render :action => "edit"
    end
  end

  def destroy
    @study = Study.find(params[:id])
    @study.deleted = true

    if (!@study.is_activated? || @study.has_ended?) && @study.save
      flash[:notice] = t('studies.messages.deleted')
    else
      flash[:alert] = t('studies.messages.not_finished_study_deletion')
    end
    redirect_to studies_url
  end

  def assign
    # TODO: not complete, form fehlt
    @moderators = User.where(:role => 'moderator').collect {|u| [u.name, u.id] }

    if request.method == "POST"
      if params[:study][:moderator]
        @study.moderator = User.find(params[:study][:moderator])

        if @study.save
          flash[:notice] = t('studies.messages.moderator_changed')
        else
          flash[:alert] = t('studies.messages.moderator_not_changed')
        end
      else
        flash[:alert] = t('studies.messages.moderator_not_changed')
      end
      redirect_to studies_url
    end
  end

  def activate
    if @study.activate && @study.save
      flash[:notice] = t('studies.messages.activated')
    else
      flash[:alert] = t('studies.messages.not_activated')
    end
    redirect_to study_url(@study.id)
  end

  private

  def get_study
    @study      = Study.find(params[:study_id])
  end
end
