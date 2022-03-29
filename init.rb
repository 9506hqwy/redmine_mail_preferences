# frozen_string_literal: true

basedir = File.expand_path('../lib', __FILE__)
libraries =
  [
    'redmine_mail_preferences/mail_preferences_helper',
    'redmine_mail_preferences/users_helper_patch',
    # require helper module before other.
    'redmine_mail_preferences/document_patch',
    'redmine_mail_preferences/issue_patch',
    'redmine_mail_preferences/journal_patch',
    'redmine_mail_preferences/message_patch',
    'redmine_mail_preferences/my_controller_patch',
    'redmine_mail_preferences/news_patch',
    'redmine_mail_preferences/project_patch',
    'redmine_mail_preferences/projects_helper_patch',
    'redmine_mail_preferences/users_controller_patch',
    'redmine_mail_preferences/user_patch',
    'redmine_mail_preferences/utils',
    'redmine_mail_preferences/view_listener',
    'redmine_mail_preferences/wiki_content_patch',
  ]

libraries.each do |library|
  require_dependency File.expand_path(library, basedir)
end

Redmine::Plugin.register :redmine_mail_preferences do
  name 'Redmine Mail Preferences plugin'
  author '9506hqwy'
  description 'This is a mail user preferences plugin for Redmine'
  version '0.2.0'
  url 'https://github.com/9506hqwy/redmine_mail_preferences'
  author_url 'https://github.com/9506hqwy'

  project_module :mail_preferences do
    permission :edit_mail_preferences, { project_mail_preferences: [:update] }
  end
end
