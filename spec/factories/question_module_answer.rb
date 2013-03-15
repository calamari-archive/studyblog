FactoryGirl.define do
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
end
