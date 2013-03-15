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
end
