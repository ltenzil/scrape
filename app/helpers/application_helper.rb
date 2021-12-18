module ApplicationHelper
  
  def fetch_name
    return unless current_user
    current_user.email.split('@').first
  end

end
