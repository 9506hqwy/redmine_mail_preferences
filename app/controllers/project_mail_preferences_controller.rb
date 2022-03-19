# frozen_string_literal: true

class ProjectMailPreferencesController < ApplicationController
  include RedmineMailPreferences::MailPreferencesHelper

  before_action :find_project_by_project_id, :authorize

  def update
    if update_project_mail_preferences
      flash[:notice] = l(:notice_successful_update)
    end

    redirect_to settings_project_path(@project, tab: :mail_preferences)
  end
end
