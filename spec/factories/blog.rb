FactoryGirl.define do
  factory :blog do
    group { FactoryGirl.create(:group) }
    user { FactoryGirl.create(:participant, :group_id => group.id) }
  end
end
