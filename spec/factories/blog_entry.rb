FactoryGirl.define do
  factory :blog_entry do
    title "Title"
    text  "A Text"
    author { FactoryGirl.create(:user, :group_id => FactoryGirl.create(:group).id) }
    blog do
      user = User.find(author_id)
      user.create_blog unless user.blog
      user.blog
    end
  end
end
