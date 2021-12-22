module ApplicationHelper
  
  def fetch_name
    return unless current_user
    current_user.email.split('@').first
  end

  def titleize(value)
    value.is_a?(String) ? value.titleize : ''
  end

end
