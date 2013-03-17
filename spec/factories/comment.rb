FactoryGirl.define do
  factory :comment do
    text  "An awesome comment"
    author { FactoryGirl.create(:user, :group_id => FactoryGirl.create(:group).id) }
    blog_entry { FactoryGirl.create(:blog_entry, :blog_id => FactoryGirl.create(:blog).id) }
  end
end
