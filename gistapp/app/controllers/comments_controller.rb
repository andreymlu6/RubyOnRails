class CommentsController < ApplicationController

  def index
    @status_id = params[:status_id]
    @status = Status.find(@status_id)
    @comments = @status.comments
    @comment = @status.comments.build
    respond_to do |format|
      format.js
    end
  end

  def create
    if current_user
    @comment = Comment.new(params[:comment])
    @parent_id = nil
    @comment.user = current_user
    if @comment.save
      flash[:notice] = "Your reply has been posted successfully"
    else
      flash[:error] = "#{@comment.errors.full_messages.join(',')}"
    end
    @status = @comment.status
    @status_id = @status.id
    @comments = @status.comments
    @comment = @status.comments.build
    else
      flash[:error] = "You need to be logged in first"
    end
    respond_to do |format|
      format.js
    end
  end

  def new_child_comment
    @parent_comment = Comment.find(params[:id])
    @comment = Comment.new(parent_id: @parent_comment.id)
    respond_to do |format|
      format.js
    end
  end

  def create_child_comment
    if current_user
    @comment = Comment.new(params[:comment])
    @comment.user = current_user

    @parent_comment = Comment.find(params[:id])
    @status = @parent_comment.root.status
    @comment.status = @status
    if @comment.save
      flash[:notice] = "Your reply has been posted successfully"
    else
      flash[:error] = "#{@comment.errors.full_messages.join(',')}"
    end
    @comments = @status.comments
    @comment = @status.comments.build
    @status_id = @status.id
    else
      flash[:error] = "You need to be logged in first"
    end
    respond_to do |format|
      format.js
    end
  end

  def up_vote
    @comment_for_vote = Comment.find(params[:comment_id])
    @status = @comment_for_vote.root.status
    @comments = @status.comments
    @comment = @status.comments.build
    @user = current_user
    begin
      @comment_for_vote.add_evaluation(:up_vote, 1, @user)
      flash[:notice] = "Your vote has been successfully submitted"
    rescue
      if current_user.nil?
        flash[:error] = "You need to be logged in first"
      else
        flash[:error] = "You have already submitted a vote"
      end
    end
  end



end
