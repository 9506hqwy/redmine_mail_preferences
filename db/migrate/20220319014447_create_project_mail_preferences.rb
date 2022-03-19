# frozen_string_literal: true

class CreateProjectMailPreferences < RedmineMailPreferences::Utils::Migration
  def change
    create_table :project_mail_preferences do |t|
      t.belongs_to :project, null: false, foreign_key: true
      t.string :disable_notified_events
    end
  end
end
