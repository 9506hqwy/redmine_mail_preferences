# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class DocumentTest < ActiveSupport::TestCase
  fixtures :documents,
           :enabled_modules,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :user_mail_preferences

  def setup
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['document_added']
    m.save!
  end

  def test_notified_users_disable
    document = documents(:documents_001)
    u = deliver_document_added(document)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_enable
    document = documents(:documents_001)
    u = deliver_document_unknown(document)
    assert_equal 2, u.length
    assert_include users(:users_002), u
    assert_include users(:users_003), u
  end

  private

  def deliver_document_added(document)
    document.notified_users
  end

  def deliver_document_unknown(document)
    document.notified_users
  end
end
