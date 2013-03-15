FactoryGirl.define do
  factory :conversation do
    subject "test conversation"
    usera { FactoryGirl.create(:moderator) }
    userb { FactoryGirl.create(:moderator) }

    after(:create) do |conversation, evaluator|
      FactoryGirl.create(:message, :conversation => conversation)
    end
  end

  factory :empty_conversation, :class => :conversation do
    subject "test conversation"
    usera { FactoryGirl.create(:moderator) }
    userb { FactoryGirl.create(:moderator) }
  end
end
