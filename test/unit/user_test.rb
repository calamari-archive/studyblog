require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test "user role is participant initially" do
    assert_equal 'participant', @user.role
  end

  test "user roles and needed group_id" do
    @user.username = 'Bill'
    assert !@user.valid?
    assert_equal I18n.t("activerecord.errors.models.user.attributes.group_id.blank"), @user.errors[:group_id][0], "group_id should be set, when participant"

    @user.role = "spectator"
    assert !@user.valid?
    assert_equal I18n.t("activerecord.errors.models.user.attributes.group_id.blank"), @user.errors[:group_id][0], "group_id should be set, when spectator"

    @user.role = "moderator"
    assert @user.valid?, "moderator needs no group_id"

    @user.role = "admin"
    assert @user.valid?, "admin needs no group_id"
  end

  test "deactivation of users" do
    @user.active = true
    assert !@user.deactivated

    @user.active = false

    assert !@user.active
    assert @user.deactivated
  end

  test "participants are only active if study is" do
    @user.group = groups(:group_in_preparing_study)
    assert !@user.active, "study is not active so should the participant"

    @user.group = groups(:group_in_running_study)
    assert @user.active, "study is running so the participant should be active"

    @user.group = groups(:group_in_closed_study)
    assert !@user.active, "study is ended so the participant should be not active anymore"
  end


  test "spectators are only active since the study begins" do
    @user.role = 'spectator'

    @user.group = groups(:group_in_preparing_study)
    assert !@user.active, "study is not active so should the spectator"

    @user.group = groups(:group_in_running_study)
    assert @user.active, "study is running so the spectator should be active"

    @user.group = groups(:group_in_closed_study)
    assert @user.active, "study is ended but the spectator should be still active"
  end

  test "if moderated_studies works" do
    admin_studies = users(:admin).moderated_studies
    puts admin_studies.inspect
    assert_equal 0, admin_studies.count, "the admin should have no study"

    mod1_studies = users(:mod1).moderated_studies
    assert_equal 1, mod1_studies.count, "mod1 should have one study"

    mod2_studies = users(:mod2).moderated_studies
    assert_equal 2, mod2_studies.count, "mod2 should have two studies"
  end
end
