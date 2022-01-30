# frozen_string_literal: true

module RedmineMailPreferences
  module Utils
    if ActiveRecord::VERSION::MAJOR >= 5
      Migration = ActiveRecord::Migration[4.2]
    else
      Migration = ActiveRecord::Migration
    end

    def self.disable_event_for(user, events)
      return false if user.mail_preferences.blank?

      disables = user.mail_preferences.disable_notified_events || []
      (events - disables).blank?
    end

    def self.remove_by_disabled_event(container, users)
      caller_method = caller_locations(2, 1)[0].base_label
      notified_events = method_to_event(container, caller_method)
      return users unless notified_events

      users.reject! { |u| disable_event_for(u, notified_events) }
      users
    end

    def self.method_to_event(container, method)
      if ['deliver_issue_add'].include?(method)
        return ['issue_added']
      end

      if ['deliver_issue_edit'].include?(method)
        # TODO
        return ['issue_updated']
      end

      if ['document_added', 'deliver_document_added'].include?(method)
        return ['document_added']
      end

      if ['attachments_added', 'deliver_attachments_added'].include?(method)
        if container.is_a?(Document)
          return ['document_added']
        else
          return ['file_added']
        end
      end

      if ['news_added', 'deliver_news_added'].include?(method)
        return ['news_added']
      end

      if ['news_comment_added', 'deliver_news_comment_added'].include?(method)
        return ['news_comment_added']
      end

      if ['message_posted', 'deliver_message_posted'].include?(method)
        return ['message_posted']
      end

      if ['wiki_content_added', 'deliver_wiki_content_added'].include?(method)
        return ['wiki_content_added']
      end

      if ['wiki_content_updated', 'deliver_wiki_content_updated'].include?(method)
        return ['wiki_content_updated']
      end

      nil
    end
  end
end