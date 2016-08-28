module NavigationHelper
  def navigation_link(title, path, active_controller, active_action = nil)
    if active_action.present?
      matches = request[:controller] == active_controller &&
                request[:action] == active_action

      css_class = matches ? "active" : ""
    else
      css_class = request[:controller] == active_controller ? "active" : ""
    end

    content_tag(:li, class: css_class) do
      link_to(title, path)
    end
  end
end