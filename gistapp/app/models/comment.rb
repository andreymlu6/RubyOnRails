class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :status
  attr_accessible :content, :status_id, :user_id, :ancestry, :parent_id

  has_ancestry

  has_reputation :up_vote,
                 :source => :user

end
