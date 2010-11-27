module ApplicationHelper
  def current_city
    "#{current_location.city}, #{current_location.state}"
  end
end
