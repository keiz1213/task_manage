module ApplicationHelper
  def user_tag_names(user)
    Tag.user_tags(user).map(&:name).uniq
  end
end
