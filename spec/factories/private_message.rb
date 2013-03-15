FactoryGirl.define do
  # DEPRECATED!
  factory :private_message do
    subject "I am a test-title"
    text  "I am a test-body"
    recipient { FactoryGirl.create(:user) }
    author { FactoryGirl.create(:user) }
  end
end
