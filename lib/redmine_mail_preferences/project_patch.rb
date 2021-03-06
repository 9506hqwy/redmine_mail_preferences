# frozen_string_literal: true

module RedmineMailPreferences
  module ProjectPatch
  end

  module ProjectPatch4
    def self.included(base)
      base.class_eval do
        has_one(:mail_preferences, class_name: :ProjectMailPreference, dependent: :destroy)
        alias_method_chain(:notified_users, :mail_preferences)
      end
    end

    def notified_users_with_mail_preferences
      RedmineMailPreferences::Utils.remove_by_disabled_event(self, notified_users_without_mail_preferences)
    end
  end

  module ProjectPatch5
    def self.prepended(base)
      base.class_eval do
        has_one(:mail_preferences, class_name: :ProjectMailPreference, dependent: :destroy)
      end
    end

    def notified_users
      RedmineMailPreferences::Utils.remove_by_disabled_event(self, super)
    end
  end
end

if ActiveSupport::VERSION::MAJOR >= 5
  Project.prepend RedmineMailPreferences::ProjectPatch5
else
  Project.include RedmineMailPreferences::ProjectPatch4
end
