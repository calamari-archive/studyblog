FactoryGirl.define do
  factory :topic do
    sequence(:title) {|n| "test_topic#{n}" }
    group { FactoryGirl.create(:group) }
  end
end
