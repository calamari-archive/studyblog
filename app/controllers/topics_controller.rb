class TopicsController < ApplicationController
  load_and_authorize_resource :group

  def new
    @group = Group.find(params[:group_id])
  end

  def create
    if params[:module]
      redirect_to new_module_group_path(params[:group_id])
      return
    end
    @group = Group.find(params[:group_id])
    @topic.group = @group

    if @topic.save
      flash[:notice] = t('topics.messages.created')
    else
      flash[:alert] = t('topics.messages.creation_failed', :reason => @topic.errors.first[1])
    end
    redirect_to @group.study
  end

  def destroy
    if topic.study.has_started?
      redirect_to study_url(@topic.study), :notice => I18n.t("topics.messages.not_deleted_started")
    else
      @topic.destroy

      redirect_to study_url(@topic.study), :notice => I18n.t("topics.messages.deleted")
    end
  end

  helper_method :available_blog_modules
  def available_blog_modules
    return [] unless StudyBlog::Application.config.app_config['blog_modules']
    StudyBlog::Application.config.app_config['blog_modules']['types'] || []
  end
end
