class CommentsController < ApplicationController
  def create
    @comment = Comment.new(params[:comment])
    entry = BlogEntry.find(params[:blog_entry_id])
    @comment.blog_entry = entry
    @comment.author = current_user

    if @comment.save
      flash[:notice] = t('blogs.messages.comment_created')
    end

    redirect_to blog_path(entry.blog, :anchor => "entry-" + entry.id.to_s)
  end
end
