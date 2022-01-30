# frozen_string_literal: true

require_dependency 'mail_preferences/mail_preferences_helper'
require_dependency 'mail_preferences/users_helper_patch'
# require helper module before other.
require_dependency 'mail_preferences/document_patch'
require_dependency 'mail_preferences/issue_patch'
require_dependency 'mail_preferences/journal_patch'
require_dependency 'mail_preferences/message_patch'
require_dependency 'mail_preferences/my_controller_patch'
require_dependency 'mail_preferences/news_patch'
require_dependency 'mail_preferences/project_patch'
require_dependency 'mail_preferences/users_controller_patch'
require_dependency 'mail_preferences/user_patch'
require_dependency 'mail_preferences/utils'
require_dependency 'mail_preferences/view_listener'
require_dependency 'mail_preferences/wiki_content_patch'

Redmine::Plugin.register :redmine_mail_preferences do
  name 'Redmine Mail Preferences plugin'
  author '9506hqwy'
  description 'This is a mail user preferences plugin for Redmine'
  version '0.1.0'
  url 'https://github.com/9506hqwy/redmine_mail_preferences'
  author_url 'https://github.com/9506hqwy'
end
