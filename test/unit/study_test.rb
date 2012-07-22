require 'test_helper'

class StudyTest < ActiveSupport::TestCase
  setup do
    @study = Study.new :title => 'Just a study', :start_date => Time.now + 2.days, :end_date => Time.now + 4.days
  end

  test "end_date is after start_date is after now validations" do
    admin = User.new(:nickname => 'Admin', :username => 'admin', :email => 'admin@admin.local', :password => 'admin', :password_confirmation => 'admin', :role => 'admin')
      study = Study.new :title => 'Test'
      assert !study.valid?
      assert_equal I18n.t("activerecord.errors.models.study.attributes.end_date.blank"), study.errors[:end_date][0], "end_date should not be saved empty"
      assert_equal I18n.t("activerecord.errors.models.study.attributes.start_date.blank"), study.errors[:start_date][0], "start_date should not be saved empty"

      study.start_date = Time.now - 2.days
      assert !study.valid?
      assert study.errors[:start_date][0].starts_with?("start_date is not after"), "start_date should be after actual time"

      study.start_date = Time.now + 2.days
      study.end_date = Time.now + 1.days
      assert !study.valid?
      assert study.errors[:end_date][0].starts_with?("end_date is not after start_date"), "end_date should be after start_date"

      study.end_date = Time.now + 2.days + 1.minute
      assert study.valid?

      study.start_date = nil
      assert !study.valid?
  end

  test "activating a study needs at least one participant" do
    assert !@study.is_activatable?, 'Study should not be activatable when having no participants'
    @study.activate
    assert !@study.is_activated?, 'Study should not be activated when having no participants'
    assert @study.save

    group = Group.new :title => 'A group'
    @study.groups << group

    assert !@study.is_activatable?, 'Study should not be activatable when having no participants'
    @study.activate
    assert !@study.is_activated?, 'Study should not be activated when having only empty groups'

    group.participants << create_user

    assert @study.is_activatable?, 'Study should be activatable when having at least one participant'

    @study.activate
    assert @study.is_activated?, 'Study should now be activatable'
    assert @study.valid?
  end

  test "a deleted study needs no other validations" do
    @study.start_date = Time.now - 2.days
    @study.end_date   = nil
    @study.title = ''
    assert !@study.valid?, 'not deleted study should not be valid without data'

    @study.deleted = true
    @study.valid?
    assert @study.valid?, 'deleted study should need no data'
  end

  test "activating a study activates also the user accounts" do
    @study.save

    @study.groups.create :title => 'A group'
    group = @study.groups.first
    group.participants << create_user

    assert @study.save, "study should be saveable"

    assert !group.participants.first.active, "newly generated participant in not active study should also be inactive"

    @study.activate
    assert @study.is_activated?, 'Study should now be activatable'

    assert @study.save, "study should be saveable"
    assert group.participants.first.active, "participant should be active after activating a study"
    the_participant = User.find(group.participants.first.id)
    assert the_participant.active, "the activation should of course be persisted to db"
  end

  test "mailing_defined?" do
    @study.save
    assert !@study.mailing_defined?, "we have no mailing defined yet"

    @study.mailing = Mailing.new :text => 'lalala'
    assert @study.mailing_defined?, "now a mailing should be defined"
  end

  test "ended studies are still activated" do
    #TODO
  end

  test "getting of spectators" do
    @study.save
    @study.groups.create :title => 'A group'
    group = @study.groups.first
    group.participants << create_user
    group.save
    spec1 = User.create :username => 'spec1', :email => 'spec@a.de', :password => 'pass1234', :password_confirmation => 'pass1234', :role => 'spectator'
    spec1.group = group
    spec1.save

    spec2 = User.create :username => 'spec2', :email => 'spec2@a.de', :password => 'pass1234', :password_confirmation => 'pass1234', :role => 'spectator'
    spec2.group = group
    spec2.save

    assert_equal 2, @study.spectators.count, 'We should have two spectators'
  end
end
