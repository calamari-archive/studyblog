FactoryGirl.define do
  factory :group do
    sequence(:title) {|n| "test_group#{n}" }
    study { FactoryGirl.create(:study) }
  end
end
