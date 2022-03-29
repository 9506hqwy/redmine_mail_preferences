# frozen_string_literal: true

module RedmineMailPreferences
  module UsersControllerPatch
  end

  module UsersControllerPatch4
    # Include here because `UsersController` does not include `UsersHelper` in Redmine3.
    include RedmineMailPreferences::MailPreferencesHelper

    def self.included(base)
      base.class_eval do
        alias_method_chain(:edit, :mail_preferences)
        alias_method_chain(:update, :mail_preferences)
      end
    end

    def edit_with_mail_preferences
      edit_without_mail_preferences
      user_mail_preferences
    end

    def update_with_mail_preferences
      update_without_mail_preferences
      update_user_mail_preferences
    end
  end

  module UsersControllerPatch5
    def edit
      super
      user_mail_preferences
    end

    def update
      super
      update_user_mail_preferences
    end
  end
end

if ActiveSupport::VERSION::MAJOR >= 5
  UsersController.prepend RedmineMailPreferences::UsersControllerPatch5
else
  UsersController.include RedmineMailPreferences::UsersControllerPatch4
end
