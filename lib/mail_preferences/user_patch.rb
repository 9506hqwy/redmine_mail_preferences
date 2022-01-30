# frozen_string_literal: true

module RedmineMailPreferences
  module UserPatch
    def self.prepended(base)
      base.class_eval do
        has_one :mail_preferences, class_name: :UserMailPreference, dependent: :destroy
      end
    end
  end
end

User.prepend RedmineMailPreferences::UserPatch
