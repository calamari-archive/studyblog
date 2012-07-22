require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test "get entries of a blog" do
    topic1 = topics(:topic1)

    assert_equal 2, topic1.blog_entries_of_blog(blogs(:blog_with_topics1)).count
    assert_equal 1, topic1.blog_entries_of_blog(blogs(:blog_with_topics2)).count

    topic2 = topics(:topic2)

    assert_equal 1, topic2.blog_entries_of_blog(blogs(:blog_with_topics1)).count
  end
end
