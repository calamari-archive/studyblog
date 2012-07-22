require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  test "if blog is writable" do
    blogs = {
      :blog_in_closed_study => false,
      :blog_in_running_study => true,
      :blog_in_active_study => false,
      :blog_in_preparing_study => false
    }
    blogs.each do |name, value|
      assert_equal value, blogs(name).is_writable?
    end
  end

  test "writing permissions" do
    blog = blogs(:blog_in_running_study)

    assert blog.permitted_to_write?(users(:participant_and_blog_owner))
    assert !blog.permitted_to_write?(users(:participant_without_blog))
  end

  test "getting actual topic" do
    study = Study.new :title => "study me"
    study.save
    group = Group.new :title => "group me"
    group.study = study
    group.save
    blog = Blog.new
    blog.user = create_user
    blog.group = group
    assert_nil blog.actual_topic, 'there should be no actual topic if none set'

    topic1 = Topic.new :title => "topic one"
    group.topics << topic1
    group.save
    assert_equal topic1, blog.actual_topic, 'topic1 should be the actual topic'

    topic2 = Topic.new :title => "topic two"
    group.topics << topic2
    group.save
    assert_equal topic2, blog.actual_topic, 'topic2 should be the actual topic now'
  end

  test "module is not delivered as actual_topic" do
    study = Study.new :title => "study me"
    study.save
    group = Group.new :title => "group me"
    group.study = study
    group.save
    blog = Blog.new
    blog.user = create_user
    blog.group = group
    assert_nil blog.actual_topic, 'there should be no actual topic if none set'

    topic1 = Topic.new :title => "topic one"
    topic1.module = QuestionModule.new
    group.topics << topic1
    group.save
    assert_nil blog.actual_topic, 'there should be no actual topic if first one is a module'

    topic2 = Topic.new :title => "topic two"
    group.topics << topic2
    group.save
    assert_equal topic2, blog.actual_topic, 'topic2 should be the actual topic now'

    topic3 = Topic.new :title => "topic third"
    topic3.module = QuestionModule.new
    group.topics << topic3
    group.save
    assert_equal topic2, blog.actual_topic, 'the last topic should be the actual one if the last one is a module'
  end

  test "getting list of entries sorted after topics" do
  return
    blog = blogs(:blog_for_topic_test)
    entries = blog.topic_sorted_entries
    puts entries[0].inspect
    assert_nil entries[0].topic, "first entry should have no topic"
    assert_equal blog_entries(:entry0).title, entries[0].title, "first entry should be the right one"

    # topic 1
    assert_equal topics(:topic1), entries[1].topic, "first entry should have no topic"
    assert_equal blog_entries(:entry1).title, entries[1].title, "first entry should be the right one"
    assert_equal topics(:topic1), entries[2].topic, "first entry should have no topic"
    assert_equal blog_entries(:entry2).title, entries[2].title, "first entry should be the right one"

    #topic 3
    assert_equal topics(:topic3), entries[3].topic, "first entry should have no topic"
    assert_equal blog_entries(:entry3).title, entries[3].title, "first entry should be the right one"
  end
end
