FactoryGirl.define do
  factory :mailing do
    text "default mailing text"
    study { FactoryGirl.create(:study) }
  end
end
