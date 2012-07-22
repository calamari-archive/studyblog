class GroupsController < ApplicationController
  def new
    @study = Study.find(params[:study_id])
    return if check_study_status @study
    @group = Group.new
  end

  def edit
    @group = Group.find(params[:id])
    return if check_study_status @group.study
  end

  def create
    @group = Group.new(params[:group])
    @study = Study.find(params[:study_id])
    @group.study = @study
    return if check_study_status @study

    if @group.save
      redirect_to study_path(@study), :notice => I18n.t("groups.messages.created")
    else
      render :action => "new"
    end
  end

  def update
    @group = Group.find(params[:id])
    return if check_study_status @group.study

    if @group.update_attributes(params[:group])
      redirect_to @group, :notice => 'Group was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @group = Group.find(params[:id])
    return if check_study_status @group.study
    @group.destroy

    redirect_to study_url(@group.study), :notice => I18n.t("groups.messages.deleted")
  end

  def edit_startpage
    @group = Group.find(params[:group_id])

    if request.method == "POST"
      @group.startpage = params[:group][:startpage]
      if @group.save
        redirect_to study_path(@group.study), :notice => I18n.t("groups.messages.startpage_edited")
      end
    end
  end

  def timeline
    @group = Group.find(params[:group_id])
  end

  def summary
    @group = Group.find(params[:group_id])
  end

  protected

    def check_study_status(study)
      #TODO: test this switch
      if study.is_activated?
        flash[:alert] = I18n.t('groups.messages.study_already_activated')
        redirect_to study_url(study)
        return true
      end
    end
end
