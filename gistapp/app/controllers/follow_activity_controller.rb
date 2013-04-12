class FollowActivityController < ApplicationController
  def follow
    respond_to do |format|
      format.js
    end
  end

  def unfollow
    respond_to do |format|
      format.js
    end
  end

  def update_follower
    respond_to do |format|
      format.js
    end
  end
end
