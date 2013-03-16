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
    @topic = Topic.new(params[:topic])
    @topic.group = @group

    if @topic.save
      flash[:notice] = t('topics.messages.created')
    else
      flash[:alert] = t('topics.messages.creation_failed', :reason => @topic.errors.first[1])
    end
    redirect_to @group.study
  end

  helper_method :available_blog_modules
  def available_blog_modules
    return [] unless StudyBlog::Application.config.app_config['blog_modules']
    StudyBlog::Application.config.app_config['blog_modules']['types'] || []
  end
end
