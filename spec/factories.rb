FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "test_user#{n}" }
    nickname { username }
    email { "#{username}@some-mailer.de".downcase }
    sequence(:password) {|n| "password#{n}" }
    password_confirmation { password }
    active true

    factory :participant do
      group_id { FactoryGirl.create(:group).id }
      role 'participant'
    end

    factory :moderator do
      role 'moderator'
    end

    factory :admin do
      role 'admin'
    end

    factory :spectator do
      group { FactoryGirl.create(:group) }
      role 'spectator'
    end
  end

  factory :blog_entry do
    title "Title"
    text  "A Text"
    author { FactoryGirl.create(:user) }
    blog do
      user = User.find(author_id)
      user.create_blog unless user.blog
      user.blog
    end
  end

  factory :group do
    sequence(:title) {|n| "test_group#{n}" }
    study { FactoryGirl.create(:study) }
  end

  factory :study do
    moderator { FactoryGirl.create(:moderator) }
    sequence(:title) {|n| "test_study#{n}" }
    start_date { Time.now + 1.day}
    end_date { Time.now + 8.day}
  end

  factory :topic do
    sequence(:title) {|n| "test_topic#{n}" }
    group { FactoryGirl.create(:group) }
  end

  factory :question_module do
    factory :free_text_question do
      possible_answers "first?\nlast?"
      question_type "free_text"
      topic { FactoryGirl.create(:topic) }
    end

    factory :likert_question do
      question_type "likert"
      number_steps 5
      left_extreme "fully agree"
      right_extreme "fully disagree"
    end
  end

  factory :question_module_answer do
    factory :free_text_answer do
      question_module_id { FactoryGirl.create(:free_text_question).id }
      answers "This is an Answer to everything!"
    end

    factory :likert_answer do
      question_module_id { FactoryGirl.create(:likert_question).id }
      answers "1,5"
    end

    after(:create) do |answer, evaluator|
      FactoryGirl.create(:blog_entry, :module_answer_id => answer)
    end
  end

  # DEPRECATED!
  factory :private_message do
    subject "I am a test-title"
    text  "I am a test-body"
    recipient { FactoryGirl.create(:user) }
    author { FactoryGirl.create(:user) }
  end

  factory :message do
    author { FactoryGirl.create(:moderator) }
    content "I am a test message"
  end

  factory :empty_conversation, :class => :conversation do
    subject "test conversation"
    usera { FactoryGirl.create(:moderator) }
    userb { FactoryGirl.create(:moderator) }
  end

  factory :conversation do
    subject "test conversation"
    usera { FactoryGirl.create(:moderator) }
    userb { FactoryGirl.create(:moderator) }

    after(:create) do |conversation, evaluator|
      FactoryGirl.create(:message, :conversation => conversation)
    end
  end
end
