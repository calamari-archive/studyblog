class BlogsController < ApplicationController
  filter_access_to :all

  def index
    @blogs = Blog.all
  end

  def show
    if params[:id]
      @blog = Blog.find(params[:id])
    else
      @group = Group.find(params[:group_id])
      @blog  = @group.groupblog
    end

    redirect_to root_url, :alert => t('blogs.messages.can_not_see_blog') unless @blog.permitted_to_read?(current_user)

    @entries = @blog.entries
  end

  def add_image
    @blog = Blog.find(params[:blog_id])
    @image = Image.new params[:image]
    @image.user = current_user

    result = {}
    if @image.save
      result[:image] = root_url + @image.image.url.slice(1..-1)
      result[:success] = t('blogs.messages.add_image_succeeded')
    else
      result[:error] = t('blogs.messages.add_image_failed')
    end
    render :json => result

    #redirect_to new_blog_blog_entry_path(@blog)
  end
end
