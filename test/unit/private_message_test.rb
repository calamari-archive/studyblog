require 'test_helper'

class PrivateMessageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "validations of writing a message" do
    pm = PrivateMessage.new
    assert !pm.valid?, "nothing entered should be not valid"

    assert pm.errors[:subject]
    assert pm.errors[:text]
    assert pm.errors[:recipient]
    assert pm.errors[:author]
    pm.subject = "my sub"
    pm.text    = "lala"
    pm.author    = users(:admin)
    pm.recipient = users(:mod1)
    assert pm.valid?, "all entered should be pass"
  end

  test "messages can only be send between participants of a group" do
    pm = PrivateMessage.new :subject => 'subject', :text => 'faerfioaerj', :author => users(:participant_without_blog)
    pm.recipient = users(:user_with_blog_and_topics1)
    assert !pm.valid?, 'participants of two different groups should not be able to write each other'

    pm.recipient = users(:participant_and_blog_owner)
    assert pm.valid?, 'participants of same groups should be able to write each other'

    pm.recipient = users(:mod3)
    assert pm.valid?, 'participants should be able to write his moderator'

    pm.recipient = users(:mod2)
    assert !pm.valid?, 'participants should not be able to write moderators of other groups'

    pm.recipient = users(:admin)
    assert pm.valid?, 'participants should be able to write to an admin'
  end

  test "spectators can only send to his moderator and admin" do
    pm = PrivateMessage.new :subject => 'subject', :text => 'faerfioaerj', :author => users(:spectator_for_running_study)
    pm.recipient = users(:user_with_blog_and_topics1)
    assert !pm.valid?, 'spectator should not be able to write participants of same group'

    pm.recipient = users(:participant_and_blog_owner)
    assert !pm.valid?, 'spectator should not be able to write participants of other groups'

    pm.recipient = users(:mod3)
    assert pm.valid?, 'spectator should be able to write his moderator'

    pm.recipient = users(:mod2)
    assert !pm.valid?, 'spectator should not be able to write moderators of other groups'

    pm.recipient = users(:admin)
    assert pm.valid?, 'spectator should be able to write to an admin'

    pm.recipient = users(:spectator2_for_running_study)
    assert !pm.valid?, 'spectator should not be able to write other spectators'
  end

  test "get conversation" do
    me = users(:spectator_for_running_study)
    pm1 = PrivateMessage.new :subject => 'subject1', :text => 'bla', :author => me, :recipient => users(:admin)
    pm1.save!
    pm2 = PrivateMessage.new :subject => 'subject2', :text => 'bla', :author => users(:admin), :recipient => me
    pm2.save!
    pm3 = PrivateMessage.new :subject => 'subject3', :text => 'bla', :author => me, :recipient => users(:mod3)
    pm3.save!

    pms = PrivateMessage.conversation(me.id, users(:admin).id)
    assert_equal 2, pms.count, 'there should be two message between you and admin'

    pms = PrivateMessage.conversation(me.id, users(:mod3).id)
    assert_equal 1, pms.count, 'there should be one message between you and mod3'
  end
end
