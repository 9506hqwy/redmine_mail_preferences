# frozen_string_literal: true

class CreateUserMailPreferences < RedmineMailPreferences::Utils::Migration
  def change
    create_table :user_mail_preferences do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :disable_notified_events
    end
  end
end
