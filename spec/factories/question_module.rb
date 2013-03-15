FactoryGirl.define do
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
end
