# frozen_string_literal: true

module RedmineMailPreferences
  module ProjectsHelperPatch
    include SettingsHelper
    include RedmineMailPreferences::MailPreferencesHelper

    def mail_preferences_setting_tabs(tabs)
      action = {
        name: 'mail_preferences',
        controller: :project_mail_preferences,
        action: :update,
        partial: 'mail_preferences/show',
        label: :mail_preferences,
      }

      tabs << action if User.current.allowed_to?(action, @project)
      tabs
    end
  end

  module ProjectsHelperPatch4
    include ProjectsHelperPatch

    def self.included(base)
      base.class_eval do
        alias_method_chain(:project_settings_tabs, :mail_preferences)
      end
    end

    def project_settings_tabs_with_mail_preferences
      mail_preferences_setting_tabs(project_settings_tabs_without_mail_preferences)
    end
  end

  module ProjectsHelperPatch5
    include ProjectsHelperPatch

    def project_settings_tabs
      mail_preferences_setting_tabs(super)
    end
  end
end

if ActiveSupport::VERSION::MAJOR >= 5
  ProjectsHelper.prepend RedmineMailPreferences::ProjectsHelperPatch5
else
  ProjectsHelper.include RedmineMailPreferences::ProjectsHelperPatch4
end
