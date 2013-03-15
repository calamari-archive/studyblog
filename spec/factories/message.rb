FactoryGirl.define do
  factory :message do
    author { FactoryGirl.create(:moderator) }
    content "I am a test message"
  end
end
