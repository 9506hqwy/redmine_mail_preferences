# frozen_string_literal: true

class UserMailPreference < RedmineMailPreferences::Utils::ModelBase
  belongs_to :user

  validates :user, presence: true

  def disable_notified_events
    v = read_attribute(:disable_notified_events)
    YAML.safe_load(v) if v
  end

  def disable_notified_events=(v)
    write_attribute(:disable_notified_events, v.to_yaml.to_s)
  end
end
