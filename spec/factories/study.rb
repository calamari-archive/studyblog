FactoryGirl.define do
  factory :study do
    moderator { FactoryGirl.create(:moderator) }
    sequence(:title) {|n| "test_study#{n}" }
    start_date { Time.now + 1.day}
    end_date { Time.now + 8.day}
  end
end
