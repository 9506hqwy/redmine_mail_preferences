# frozen_string_literal: true

module RedmineMailPreferences
  module Utils
    if ActiveRecord::VERSION::MAJOR >= 5
      Migration = ActiveRecord::Migration[4.2]
    else
      Migration = ActiveRecord::Migration
    end

    if defined?(ApplicationRecord)
      # https://www.redmine.org/issues/38975
      ModelBase = ApplicationRecord
    else
      ModelBase = ActiveRecord::Base
    end

    def self.disable_event_for(target, events)
      return false if target.mail_preferences.blank?

      disables = target.mail_preferences.disable_notified_events || []
      (events - disables).blank?
    end

    def self.remove_by_disabled_event(container, users)
      caller_method = caller_locations(2, 1)[0].base_label
      notified_events = method_to_event(container, caller_method)
      return users unless notified_events

      project = container.is_a?(Project) ? container : container.project
      if project.module_enabled?(:mail_preferences) && disable_event_for(project, notified_events)
        return []
      end

      users.reject { |u| disable_event_for(u, notified_events) }
    end

    def self.method_to_event(container, method)
      if ['deliver_issue_add'].include?(method)
        return ['issue_added']
      end

      if ['deliver_issue_edit'].include?(method)
        events = ['issue_updated']

        if container.notes.present?
          events << 'issue_note_added'
        end

        if container.new_status.present?
          events << 'issue_status_updated'
        end

        if container.detail_for_attribute('assigned_to_id').present?
          events << 'issue_assigned_to_updated'
        end

        if container.detail_for_attribute('priority_id').present?
          events << 'issue_priority_updated'
        end

        if ([4, 1] <=> [Redmine::VERSION::MAJOR, Redmine::VERSION::MINOR]) <= 0 &&
            container.detail_for_attribute('fixed_version_id').present?
          events << 'issue_fixed_version_updated'
        end

        return events
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

      # for redmine_wiki_extensions 0.9.3 or later.
      if ['deliver_wiki_commented'].include?(method)
        return ['wiki_comment_added']
      end

      nil
    end
  end
end
