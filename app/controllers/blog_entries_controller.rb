class BlogEntriesController < ApplicationController
  load_and_authorize_resource

  def show
    @blog_entry = BlogEntry.find(params[:id])
  end

  def new
    @blog = Blog.find(params[:blog_id])
    topic_id = params[:topic_id]

    redirect_to @blog, :alert => t('blogs.messages.not_your_blog') unless @blog.permitted_to_write?(current_user)
    redirect_to @blog, :alert => t('blogs.messages.study_not_started_yet') unless @blog.is_writable?

    @uploaded_images = Image.where(:user_id => current_user, :blog_entry_id => nil)

    @blog_entry = BlogEntry.new :blog => @blog
    @topic = @blog.topic_with_id(topic_id.to_i) || @blog.actual_topic
  end

  def edit
    @blog_entry = BlogEntry.find(params[:id])
  end

  def create
    @blog = Blog.find(params[:blog_id])
    topic_id = params[:blog_entry][:topic_id]
    params[:blog_entry].delete(:topic_id)
    @blog_entry = BlogEntry.new(params[:blog_entry])
    @blog_entry.blog = @blog
    @blog_entry.author = current_user
    topic = @blog.topic_with_id(topic_id.to_i) || @blog.actual_topic
    @blog_entry.topic = topic if topic

    if @blog_entry.save
      redirect_to @blog, :notice => t('blogs.messages.entry_creation_failed') #TODO
    else
      render :action => "new"
    end
  end

  def update
  return#TODO?
    @blog_entry = BlogEntry.find(params[:id])

    if @blog_entry.update_attributes(params[:blog_entry])
      redirect_to(@blog_entry, :notice => 'Blog entry was successfully updated.')
    else
      render :action => "edit"
    end
  end
end
