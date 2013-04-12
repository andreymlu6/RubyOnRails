class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :profile_name, :provider, :uid, :gender, :remote_avatar_url, :phone, :bio, :address, :confirmed_at


  #validates :first_name, presence: true
  #validates :last_name, presence: true
  #validates :profile_name, presence: true,
  #          uniqueness: true,
  #          format: {
  #              with: /^[a-zA-Z0-9_-]+$/,
  #              message: 'Must be formatted correctly.'
  #          }


  has_many :statuses
  has_many :comments
  has_many :user_friendships
  has_many :friends, through: :user_friendships,
           conditions: {user_friendships: {state: 'accepted'}}

  has_many :pending_user_friendships, class_name: 'UserFriendship',
           foreign_key: :user_id,
           conditions: {state: 'pending'}
  has_many :pending_friends, through: :pending_user_friendships, source: :friend
  has_many :authentications

  acts_as_followable
  acts_as_follower


  def full_name
    first_name + " " + last_name rescue name

  end

  def to_param
    profile_name
  end

  def gravatar_url
    return remote_avatar_url unless remote_avatar_url.nil?
    stripped_email = email.strip
    downcased_email=stripped_email.downcase
    hash = Digest::MD5.hexdigest(downcased_email)
    "http://gravatar.com/avatar/#{hash}"
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    if signed_in_resource
      user = User.find(signed_in_resource.id)
    else
      user = User.where(:email => auth.info.email).first
      unless user
      user = create_user_from_facebook_oauth(auth)
      end
    end
    user
  end

  def self.create_user_from_facebook_oauth(auth)
    user = User.create(name: auth.info.name,
                       provider: auth.provider,
                       uid: auth.uid,
                       email: auth.info.email,
                       bio: auth.info.description || auth.extra.raw_info.quotes,
                       remote_avatar_url: auth.info.image.to_s.gsub("square", "large"),
                       password: Devise.friendly_token[0, 20],
                       phone: auth.info.phone,
                       address: auth.info.location,
                       gender: auth.extra.raw_info.gender,
                       confirmed_at: Time.now
    )
    user
  end

  def self.find_for_google_oauth(auth, signed_in_resource=nil)
    if signed_in_resource
      user = User.find(signed_in_resource.id)
    else
      user = User.where(:email => auth.info.email).first
      unless user
        user = User.create(name: auth.info.name,
                           provider: auth.provider,
                           uid: auth.uid,
                           bio: auth.info.description || '',
                           remote_avatar_url: auth.info.image,
                           email: auth.info.email,
                           password: Devise.friendly_token[0, 20],
                           phone: auth.info.phone || '',
                           address: auth.extra.raw_info.location || '',
                           confirmed_at: Time.now
        )
      end
    end
    user
  end


  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    if signed_in_resource
      user = User.find(signed_in_resource.id)
    else
      user = User.where(:email => auth.info.nickname + '@personlog.com').first
      unless user
        user = User.create(name: auth.info.name,
                           provider: auth.provider,
                           uid: auth.uid,
                           bio: auth.info.description,
                           remote_avatar_url: auth.info.image.to_s.gsub("_normal", ""),
                           email: auth.info.nickname + '@personlog.com',
                           password: Devise.friendly_token[0, 20],
                           phone: auth.info.phone,
                           address: auth.info.location,
                           confirmed_at: Time.now
        )
      end
    end
    user
  end

  def self.find_for_linkedin_oauth(auth, signed_in_resource=nil)
    if signed_in_resource
      user = User.find(signed_in_resource.id)
    else
      user = User.where(:email => auth.info.email).first
      unless user
        user = User.create(name: auth.info.name,
                           provider: auth.provider,
                           uid: auth.uid,
                           bio: auth.info.description + ' in ' + auth.info.industry + ' industry',
                           remote_avatar_url: auth.info.image.to_s.gsub("_normal", ""),
                           email: auth.info.email,
                           password: Devise.friendly_token[0, 20],
                           phone: auth.info.phone,
                           location: auth.extra.raw_info.location.name,
                           confirmed_at: Time.now
        )
      end
    end
    user
  end

  def self.import_linkedin_connections(user, result)
    if result
      result.all.each do |linked_in_profile|
        if linked_in_profile.present?
          usr = User.find_or_create_by_uid(
              :uid => linked_in_profile.id,
              :provider => 'linkedin',
              :bio => [linked_in_profile.headline, linked_in_profile.industry].join(', '),
              :email => [linked_in_profile.first_name.parameterize, linked_in_profile.last_name.parameterize, Devise.friendly_token[0, 20]].join('.') +'@personlog.com',
              :password => Devise.friendly_token[0, 20],
              :remote_avatar_url => linked_in_profile.picture_url,
              :name => [linked_in_profile.first_name, linked_in_profile.last_name].join(' '),
              :confirmed_at => Time.now,
              :published => true,
              :published_at => Time.now
          )
          if linked_in_profile.location
            usr.address = linked_in_profile.location.name
          end
          usr.friends << user
          usr.save
          user.friends << usr
          if linked_in_profile.public_profile_url
            usr.urls.create(:title => 'linkedin', :value => linked_in_profile.public_profile_url)
          end
          import_positions_from_linkedin(linked_in_profile, usr)
          import_educations_from_linkedin(linked_in_profile, usr)
        end #if u.present ends here
      end #result ends
    end
  end

  def self.import_educations_from_linkedin(linked_in_profile, usr)
    if linked_in_profile.educations
      linked_in_profile.educations.all.each do |education|
        Education.find_or_create_by_school_and_degree_and_user_id(:school => education.school_name, :degree => education.degree, :user_id => usr.id).tap do |edu|
          if education.start_date.present?
            if education.start_date.year.present?
              edu.start_date = Date.new(education.start_date.year, 1, 1)
            end
          end
          if education.end_date.present?
            if education.end_date.year.present?
              edu.end_date = Date.new(education.end_date.year, 1, 1)
            end
          end
          edu.field_of_study = education.field_of_study if education.field_of_study.present?
        end.save
      end
    end
  end

  def self.import_positions_from_linkedin(linked_in_profile, usr)
    if linked_in_profile.positions.present?
      if linked_in_profile.positions.all.present?
        linked_in_profile.positions.all.each do |p|
          c = Company.find_or_initialize_by_industry_and_name_and_ctype(:industry => p.company.industry, :name => p.company.name, :ctype => p.company.type)
          c.size = p.company.size if p.company.size.present?
          c.save
          if p.start_date.present?
            if p.start_date.year.present? && p.start_date.month.present?
              sd = Date.new(p.start_date.year, p.start_date.month, 1)
            else
              sd = Date.today
            end
          else
            sd = Date.today
          end
          Position.find_or_create_by_name_and_company_id_and_user_id(:name => p.title, :company_id => c.id, :user_id => usr.id).tap do |position|
            position.is_current = p.is_current
            position.summary = p.summary
            position.start_date = sd
          end.save
        end
      end
    end
  end


end


