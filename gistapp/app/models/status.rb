class Status < ActiveRecord::Base
  has_many :comments
  attr_accessible :content, :user_id, :url, :title
  belongs_to :user

  validates :user_id, presence: true

  before_validation :assign_tag

  before_save :strip_url

  validate :content_or_url_is_present
  validate :content_and_url_are_not_both_present

  has_reputation :votes,
                 :source => :user

  acts_as_taggable
  acts_as_taggable_on :tags
  acts_as_followable

  attr_accessible :tag_line
  attr_accessor :tag_line

  def content_or_url_is_present
  	if content.empty? && url.empty?
  	  errors.add(:content, " or URL must be present.")
  	end
  end

  def content_and_url_are_not_both_present
  	if !content.empty? && !url.empty?
  	  errors.add(:content, " and URL cannot both be present.")
  	end
  end

  def total_followers
    followers_by_type_count('User')
  end

  def self.search_tag(tag)

  end



  private 

  	def strip_url
	  url.sub!(/https\:\/\/www./, '') if url.include? "https://www."
	  url.sub!(/http\:\/\/www./, '')  if url.include? "http://www."
	  url.sub!(/https\:\/\//, '')  	  if url.include? "https://"
	  url.sub!(/http\:\/\//, '')  	  if url.include? "http://"
	  url.sub!(/www./, '')            if url.include? "www."
    end

    def assign_tag
      if tag_line
        tag_line.split(',').each do |tag|
           self.tag_list << tag.strip.downcase
        end
      end
    end
end
