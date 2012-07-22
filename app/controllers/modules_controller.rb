class ModulesController < ApplicationController
  def new
    @group = Group.find(params[:group_id])
    @topic = Topic.new
    @module_type = params[:module_type]
  end

  def create
    @group = Group.find(params[:group_id])
    @module_type = params[:module_type]
    @topic = Topic.new(params[:topic])
    @topic.group = @group

    if (@module_type.to_sym == :question)
      @module = QuestionModule.new(params[:module])
    else
      flash[:alert] = t('modules.messages.no_module')
      redirect_to new_topic_group_path(@group)
      return
    end
    @topic.module = @module

    if @module.save && @topic.save
      flash[:notice] = t('modules.messages.created')
      redirect_to @group.study
    else
      flash[:alert] = @module.errors.messages.values.join('<br>').html_safe
      render :new
    end
  end

  def show
    @blog = Blog.find(params[:blog_id])
    @topic = Topic.find(params[:topic_id])

    @module_type = @topic.module_type_short
    prepare_show
  end

  def answer
    @blog = Blog.find(params[:blog_id])
    @topic = Topic.find(params[:topic_id])
    return redirect_to @blog unless @topic.module.permitted_to_write?(current_user)
    @module_type = @topic.module_type_short
    @blog_entry = BlogEntry.new(params[:blog_entry])
    @blog_entry.blog = @blog
    @blog_entry.author = current_user
    @blog_entry.topic = @topic

    if (@module_type.to_sym == :question)
      @answer = QuestionModuleAnswer.new
      @answer.question_module = @topic.module
      @answer.answers = params[:answer][:answers]
    else
      flash[:alert] = t('modules.messages.no_module')
      redirect_to @blog
      return
    end
    @blog_entry.module_answer = @answer

    # TODO: transaction?
    if @answer.save && @blog_entry.save
      flash[:notice] = t('modules.messages.answer.created')
      redirect_to @blog
    else
      flash[:alert] = t('modules.messages.answer.empty')
      prepare_show
      @answer = nil
      render :show
    end
  end

private

  def prepare_show
    @module = @topic.module
    @entries = BlogEntry.where :topic_id => @topic.id, :author_id => current_user.id
    @answer = @entries[0].module_answer unless @entries.empty?
  end
end
