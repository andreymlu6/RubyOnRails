class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def twitter
    auth = request.env["omniauth.auth"]
    authentication = Authentication.where(:provider => auth.provider, :uid => auth.uid).first
    if authentication
      sign_in_and_redirect(:user, authentication.user)
      set_flash_message(:notice, :success, :kind => "Twitter") if is_navigational_format?
    else
      @user = User.find_for_twitter_oauth(auth, current_user)
      @user.authentications.create!(:raw => auth.to_json, :provider => auth.provider,
                                    :uid => auth.uid,
                                    :credentials => [auth.credentials.token.to_s, auth.credentials.secret.to_s].join(' '))
      if @user.persisted?
        set_flash_message(:notice, :success, :kind => "Twitter") if is_navigational_format?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
                                                              #set_flash_message(:notice, :success, :kind => "Twitter") if is_navigational_format?
      else
        session["devise.twitter_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end

  def facebook
    auth = request.env["omniauth.auth"]
    authentication = Authentication.where(:provider => auth.provider, :uid => auth.uid).first
    if authentication
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      sign_in_and_redirect(:user, authentication.user)
    else
      @user = User.find_for_facebook_oauth(auth, current_user)

      @user.authentications.create!(:raw => auth.to_json, :provider => auth.provider,
                                    :uid => auth.uid,
                                    :credentials => [auth.credentials.token.to_s, auth.credentials.secret
                                    .to_s].join(' '))
      if @user.persisted?
        #FacebookFactory.update_profile(@user)
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end

  def linkedin
    auth = request.env["omniauth.auth"]
    authentication = Authentication.where(:provider => auth.provider, :uid => auth.uid).first
    if authentication
      sign_in_and_redirect(:user, authentication.user)
      set_flash_message(:notice, :success, :kind => "LinkedIn") if is_navigational_format?
    else
      @user = User.find_for_linkedin_oauth(auth, current_user)
      @user.authentications.create!(:raw => auth.to_json, :provider => auth.provider,
                                    :uid => auth.uid,
                                    :credentials => [auth.credentials.token.to_s, auth.credentials.secret.to_s].join(' '))
      if @user.persisted?
        #LinkedinFactory.update_profile(@user)
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "LinkedIn") if is_navigational_format?
      else
        session["devise.linkedin_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end

  def github
    auth = request.env["omniauth.auth"]
    authentication = Authentication.where(:provider => auth.provider, :uid => auth.uid).first
    if authentication
      sign_in_and_redirect(:user, authentication.user)
      set_flash_message(:notice, :success, :kind => "GitHub") if is_navigational_format?
    else
      @user = User.find_for_github_oauth(auth, current_user)
      @user.authentications.create!(:raw => auth.to_json, :provider => auth.provider,
                                    :uid => auth.uid,
                                    :credentials => [auth.credentials.token.to_s, auth.credentials.secret.to_s].join(' '))
      if @user.persisted?
        @user.add_role :user

        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "GitHub") if is_navigational_format?
      else
        session["devise.github_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end

  def google_oauth2
    auth = request.env["omniauth.auth"]
    authentication = Authentication.where(:provider => auth.provider, :uid => auth.uid).first
    if authentication
      sign_in_and_redirect(:user, authentication.user)
      set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
    else
      @user = User.find_for_google_oauth(auth, current_user)
      @user.authentications.create!(:raw => auth.to_json, :provider => auth.provider,
                                    :uid => auth.uid,
                                    :credentials => [auth.credentials.token.to_s, auth.credentials.secret.to_s].join(' '))
      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end


  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    # Or alternatively,
    # raise ActionController::RoutingError.new('Not Found')
  end

  # This is necessary since Rails 3.0.4
  # See https://github.com/intridea/omniauth/issues/185
  # and http://www.arailsdemo.com/posts/44
  protected
  def handle_unverified_request
    true
  end

end
