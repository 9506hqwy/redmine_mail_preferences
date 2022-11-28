# frozen_string_literal: true

module RedmineMailPreferences
  module ProjectsHelperPatch
    include SettingsHelper
    include RedmineMailPreferences::MailPreferencesHelper

    def project_settings_tabs
      action = {
        name: 'mail_preferences',
        controller: :project_mail_preferences,
        action: :update,
        partial: 'mail_preferences/show',
        label: :mail_preferences,
      }

      tabs = super
      tabs << action if User.current.allowed_to?(action, @project)
      tabs
    end
  end
end

Rails.application.config.after_initialize do
  ProjectsController.send(:helper, RedmineMailPreferences::ProjectsHelperPatch)
end
