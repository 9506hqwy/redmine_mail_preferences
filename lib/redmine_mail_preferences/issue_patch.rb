# frozen_string_literal: true

module RedmineMailPreferences
  module IssuePatch
  end

  module IssuePatch4
    def self.included(base)
      base.class_eval do
        alias_method_chain(:notified_users, :mail_preferences)
      end
    end

    def notified_users_with_mail_preferences
      RedmineMailPreferences::Utils.remove_by_disabled_event(self, notified_users_without_mail_preferences)
    end
  end

  module IssuePatch5
    def notified_users
      RedmineMailPreferences::Utils.remove_by_disabled_event(self, super)
    end
  end
end

if ActiveSupport::VERSION::MAJOR >= 5
  Issue.prepend RedmineMailPreferences::IssuePatch5
else
  Issue.include RedmineMailPreferences::IssuePatch4
end
