# frozen_string_literal: true

module RedmineMailPreferences
  module MailPreferencesHelper
    def project_mail_preferences
      target_mail_preferences(@project, ProjectMailPreference)
    end

    def setting_value(setting)
      # call SettingsHelper::notification_field.
      @notified_events
    end

    def update_project_mail_preferences
      settings = params[:settings]
      return if settings.nil?

      notified_events = settings.fetch(:notified_events, [])

      prefs = @project.mail_preferences || ProjectMailPreference.new
      prefs.project = @project
      prefs.disable_notified_events = target_disable_notified_events(notified_events)
      prefs.save
    end

    def update_user_mail_preferences
      settings = params[:settings]
      return if settings.nil?

      notified_events = settings.fetch(:notified_events, [])

      prefs = @user.mail_preferences || UserMailPreference.new
      prefs.user = @user
      prefs.disable_notified_events = target_disable_notified_events(notified_events)
      prefs.save
    end

    def user_mail_preferences
      target_mail_preferences(@user, UserMailPreference)
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

    def target_disable_notified_events(enables)
      enable_children =  Redmine::Notifiable.all.select { |c| enables.any? { |e| e == c.parent } }.map { |n| n.name }
      Redmine::Notifiable.all.map { |n| n.name } - (enables | enable_children)
    end

    def target_enable_notified_events(disables)
      enables = Redmine::Notifiable.all.map { |n| n.name } - disables
      enable_children =  Redmine::Notifiable.all.select { |c| enables.any? { |e| e == c.parent } }.map { |n| n.name }
      enables - enable_children
    end

    def target_mail_preferences(target, prefs_class)
      @notifiables = global_notified_events

      prefs = target.mail_preferences || prefs_class.new
      @notified_events = target_enable_notified_events(prefs.disable_notified_events || [])
    end
  end
end
