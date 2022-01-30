# frozen_string_literal: true

module RedmineMailPreferences
  class ViewListener < Redmine::Hook::ViewListener
    render_on :view_layouts_base_body_bottom, partial: 'mail_preferences/body_bottom'
  end
end
