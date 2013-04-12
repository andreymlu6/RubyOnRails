module ApplicationHelper

  def flash_class(type)
    case type
      when :alert
        "alert-error"
      when :notice
        "alert-success"
      else
        ""
    end

  end

  def nested_messages(messages)
    messages.map do |comment, sub_messages|
      render(comment)+ content_tag(:div, nested_messages(sub_messages), :class => "offset1 span4")
    end.join.html_safe
  end

  def link_to_follow(option ={})
    user = option[:user] if option.has_key?(:user)
    status = option[:status] if option.has_key?(:status)
    if current_user
      if user.following?(status) && user && status
        (link_to 'Unfollow', '#', remote: true).html_safe + "&nbsp".html_safe + content_tag(:span, "Following "+ status.followers_count.to_s)
      elsif user && status
        (link_to "follow", '#', remote: true).html_safe + "&nbsp".html_safe + content_tag(:span, "Following "+ status.followers_count.to_s)
      end
    else
      content_tag(:span, "Following "+ status.followers_count.to_s)
    end
  end
end
