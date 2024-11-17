# Redmine Mail Preferences

This plugin provides a mail preference configuration per user or project.

## Installation

1. Download plugin in Redmine plugin directory.
   ```sh
   git clone https://github.com/9506hqwy/redmine_mail_preferences.git
   ```
2. Install plugin in Redmine directory.
   ```sh
   bundle exec rake redmine:plugins:migrate NAME=redmine_mail_preferences RAILS_ENV=production
   ```
3. Start Redmine

## Configuration

* Per user

  1. Set in [My account] page.

* Per project

  1. Enable plugin module.
     
     Check [Mail Notification] in project setting.

  2. Set in [Mail Notification] tag in project setting.

## Tested Environment

* Redmine (Docker Image)
  * 3.4
  * 4.0
  * 4.1
  * 4.2
  * 5.0
  * 5.1
  * 6.0
* Database
  * SQLite
  * MySQL 5.7 or 8.0
  * PostgreSQL 12

## References

- [#10010 Setting e-mail notifications globally project based](https://www.redmine.org/issues/10010)
- [#21234 Notification system changes in each project](https://www.redmine.org/issues/21234)
