# frozen_string_literal: true

module RedmineMailPreferences
  module UsersHelperPatch
    include SettingsHelper
    include RedmineMailPreferences::MailPreferencesHelper
  end
end

UsersHelper.include RedmineMailPreferences::UsersHelperPatch
