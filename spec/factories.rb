FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "test_user#{n}" }
    nickname { username }
    email { "#{username}@some-mailer.de".downcase }
    sequence(:password) {|n| "password#{n}" }
    password_confirmation { password }
    group_id { FactoryGirl.create(:group).id }
    active true

    factory :participant do
      role 'participant'
    end

    factory :moderator do
      role 'moderator'
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
    study_id { FactoryGirl.create(:study).id }
  end

  factory :study do
    sequence(:title) {|n| "test_study#{n}" }
    start_date { Time.now + 1.day}
    end_date { Time.now + 8.day}
  end

  factory :topic do
    sequence(:title) {|n| "test_topic#{n}" }
    group_id { FactoryGirl.create(:group).id }
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

  factory :private_message do
    subject "I am a test-title"
    text  "I am a test-body"
    recipient { FactoryGirl.create(:user) }
    author { FactoryGirl.create(:user) }
  end

  factory :message do
    author { FactoryGirl.create(:user) }
    content "I am a test message"
  end

  factory :conversation do
    usera { FactoryGirl.create(:user) }
    userb { FactoryGirl.create(:user) }
  end
end
