require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "group has to have a title and astudy for saving it" do
    @group = Group.new

    assert !@group.valid?
    assert_equal I18n.t("activerecord.errors.models.group.attributes.title.blank"),  @group.errors[:title][0], "should have a title"
#    assert_equal I18n.t("activerecord.errors.models.group.attributes.study_id.blank"),  @group.errors[:study_id][0], "should have a study associated"
  end

  test "groups should have different title in the same study" do

  end

  test "getting groupblog" do
    @group = Group.new :title => 'lala'
    @group.save!

    # create a user blog, to test, that we do not get the wrong blog as groupblog
    participant = create_user
    @group.participants << participant
    participant.create_blog
    participant.save!
    single_blog = participant.blog

    assert_equal nil, @group.groupblog, "if has_groupblog is false, we should get no blog"
    @group.has_groupblog = true
    assert_equal nil, @group.groupblog, "if has_groupblog is true but there is no groupblog, we should get no blog"
    group_blog = Blog.new :group => @group
    group_blog.save!
    @group.save!
    assert_equal group_blog, @group.groupblog, "if has_groupblog is true, we should get the blog"
  end

  test "adding a participant to a group should add the group_id to the user" do
    @group = Group.new :title => 'lala'
    assert @group.save
    participant = create_user
    @group.participants << participant
    assert_equal @group.id, participant.group_id, "shuold have sat the group id to the participant"
  end

  test "getting actual topic" do
    group = groups(:groupOfActivatableStudy)
    assert_nil group.actual_topic, 'there should be no actual topic if none set'

    topic1 = Topic.new :title => "topic one"
    group.topics << topic1
    group.save
    assert_equal topic1, group.actual_topic, 'topic1 should be the actual topic'

    topic2 = Topic.new :title => "topic two"
    group.topics << topic2
    group.save
    assert_equal topic2, group.actual_topic, 'topic2 should be the actual topic now'
  end

  test "startpage texts will be sanitized" do
    test_text = <<-EOF
      <h1>1<h2>2<h3>3<h4>4<h5>5<h6>6</h6></h5></h4></h3></h2></h1>
      <p data-attribute="forbidden">Bla <strong>bold</strong> <b>not bold</b> <em>italic</em> <i>not italic</i> <span style="text-decoration: underline;">underlined</span> <span style="text-decoration: line-through;">striked</span></p>
      <ul><li>ul-item</li></ul>
      <ol><li>ol-item</li></ol>
      <blockquote>Quote me</blockquote>
      <img src="my.jpg" alt="blabla" width="10" height="20" title="no title please">
      <a href="#" id="no-id" class="no-class-at-all">My link</a>
      <a href="gopher://linknoworking.com">not working protocol</a>
      <span style="font-family: times; font-size: 10pt; color: red;"></span>
    EOF

    result_text = <<-EOF
      <h1>1<h2>2<h3>3<h4>4<h5>5<h6>6</h6></h5></h4></h3></h2></h1>
      <p>Bla <strong>bold</strong> not bold <em>italic</em> not italic <span style="text-decoration: underline;">underlined</span> <span style="text-decoration: line-through;">striked</span></p>
      <ul><li>ul-item</li></ul>
      <ol><li>ol-item</li></ol>
      <blockquote>Quote me</blockquote>
      <img src="my.jpg" alt="blabla">
      <a href="#" rel="nofollow">My link</a>
      <a rel="nofollow">not working protocol</a>
      <span style="font-family: times; font-size: 10pt; color: red;"></span>
    EOF
    group = Group.new :title => 'bla', :startpage => test_text
    group.save!
    assert_equal result_text.gsub(/[ ]{2,}/, ' ').gsub(/\n\r?/, '').gsub(/>[ ]/, '>'), group.startpage.gsub(/[ ]{2,}/, ' ').gsub(/\n\r?/, '').gsub(/>[ ]/, '>'), "the startpage text should be sanitized"
  end
end
