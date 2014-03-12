module DeviseHelper
#  def devise_error_messages!
#    resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
#  end

  def name (email)
    p = Person.find_by(email: email)
    p ? p.full_name : email
  end

  def current_name ()
    email = current_user.email
    p = Person.find_by(email: email)
    p ? p.full_name : email
  end
end
