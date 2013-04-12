class StatusesController < ApplicationController

  before_filter :authenticate_user!, only: [:new, :create, :edit, :update]


  # GET /statuses
  # GET /statuses.json
  def index
    @statuses = Status.order("created_at DESC") unless params[:tag]
    @statuses = Status.tagged_with(params[:tag].to_s,:on => :tags ,:any => true ) if params[:tag]
    if params[:time]
     @statuses =  @statuses.where(['created_at >= ? and created_at <= ?', params[:time], Time.zone.now.end_of_day])
    end
    authorize! :read, @statuses
    respond_to do |format|
      format.html # index.js.erb
      format.json { render json: @statuses }
    end
  end

  # GET /statuses/1
  # GET /statuses/1.json
  def show
    @status = Status.find(params[:id])
    @comment = @status.comments.build
    @comments = @status.comments
    authorize! :read, @status
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @status }
    end
  end

  # GET /statuses/new
  # GET /statuses/new.json
  def new
    @status = Status.new
    authorize! :create, @status
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @status }
    end
  end

  # GET /statuses/1/edit
  def edit
    @status = Status.find(params[:id])
    authorize! :update, @status
  end

  # POST /statuses
  # POST /statuses.json
  def create
    @status = current_user.statuses.new(params[:status])
    authorize! :create, @status
    respond_to do |format|
      if @status.save
        format.html { redirect_to @status, notice: 'Status was successfully created.' }
        format.json { render json: @status, status: :created, location: @status }
      else
        format.html { render action: "new" }
        format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /statuses/1
  # PUT /statuses/1.json
  def update
    @status = current_user.statuses.find(params[:id])
    authorize! :update, @status
    if params[:status] && params[:status].has_key?(:user_id)
      params[:status].delete(:user_id)
    end
    respond_to do |format|
      if @status.update_attributes(params[:status])
        format.html { redirect_to @status, notice: 'Status was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statuses/1
  # DELETE /statuses/1.json
  def destroy
    @status = Status.find(params[:id])
    authorize! :destroy, @status
    @status.destroy

    respond_to do |format|
      format.html { redirect_to statuses_url }
      format.json { head :no_content }
    end
  end

  def vote
    @status = Status.find(params[:id])
    @user = current_user
    begin
      @status.add_evaluation(:votes, 1, @user)
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
