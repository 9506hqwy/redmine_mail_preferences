# frozen_string_literal: true

module RedmineMailPreferences
  module MailPreferencesHelper
    def setting_value(setting)
      # call SettingsHelper::notification_field.
      @notified_events
    end

    def update_user_mail_preferences
      settings = params.fetch(:settings, {})
      notified_events = settings.fetch(:notified_events, [])

      prefs = @user.mail_preferences || UserMailPreference.new
      prefs.user = @user
      prefs.disable_notified_events = user_disable_notified_events(notified_events)
      prefs.save
    end

    def user_mail_preferences
      @notifiables = global_notified_events

      prefs = @user.mail_preferences || UserMailPreference.new
      @notified_events = user_enable_notified_events(prefs.disable_notified_events || [])
    end

    private

    def global_notified_events
      notified_events = Setting.notified_events
      enables = Redmine::Notifiable.all.select { |n| notified_events.include?(n.name) }
      parents = Redmine::Notifiable.all.select { |p| enables.any? { |n| n.parent == p.name } }
      children =  Redmine::Notifiable.all.select { |c| enables.any? { |n| c.parent == n.name } }
      event_names= (enables | parents | children).map { |n| n.name }
      # Display item order.
      Redmine::Notifiable.all.select { |n| event_names.include?(n.name) }
    end

    def user_disable_notified_events(enables)
      Redmine::Notifiable.all.map { |n| n.name } - enables
    end

    def user_enable_notified_events(disables)
      Redmine::Notifiable.all.map { |n| n.name } - disables
    end
  end
end
