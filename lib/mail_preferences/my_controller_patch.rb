# frozen_string_literal: true

module RedmineMailPreferences
  module MyControllerPatch
    # Include here because `MyController` does not include `MyHelper` in Redmine3 or later.
    include RedmineMailPreferences::MailPreferencesHelper

    def account_user_mail_preferences
      yield if block_given?

      if request.post? || request.put?
        # post is for Redmine3, put is for Redmine4
        update_user_mail_preferences
      else
        user_mail_preferences
      end
    end
  end

  module MyControllerPatch4
    include MyControllerPatch

    def self.included(base)
      base.class_eval do
        alias_method_chain(:account, :mail_preferences)
      end
    end

    def account_with_mail_preferences
      account_user_mail_preferences do
        account_without_mail_preferences
      end
    end
  end

  module MyControllerPatch5
    include MyControllerPatch

    def account
      account_user_mail_preferences do
        super
      end
    end
  end
end

if ActiveSupport::VERSION::MAJOR >= 5
  MyController.prepend RedmineMailPreferences::MyControllerPatch5
else
  MyController.include RedmineMailPreferences::MyControllerPatch4
end
