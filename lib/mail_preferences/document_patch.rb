# frozen_string_literal: true

module RedmineMailPreferences
  module DocumentPatch4
    def self.included(base)
      base.class_eval do
        alias_method_chain(:notified_users, :mail_preferences)
      end
    end

    def notified_users_with_mail_preferences
      RedmineMailPreferences::Utils.remove_by_disabled_event(self, notified_users_without_mail_preferences)
    end
  end

  module DocumentPatch5
    def notified_users
      RedmineMailPreferences::Utils.remove_by_disabled_event(self, super)
    end
  end
end

if ActiveSupport::VERSION::MAJOR >= 5
  Document.prepend RedmineMailPreferences::DocumentPatch5
else
  Document.include RedmineMailPreferences::DocumentPatch4
end
