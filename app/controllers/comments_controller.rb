class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_comment

  def destroy
    if @comment.user == current_user
      @comment.destroy
    end
    respond_to do |format|
      format.turbo_stream { }
      format.html { redirect_to request.referer }
    end
  end

  private 

  def set_comment
    @comment = current_user.comments.find(params[:id])
  end
end