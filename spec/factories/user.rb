FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "test_user#{n}" }
    nickname { username }
    email { "#{username}@some-mailer.de".downcase }
    sequence(:password) {|n| "password#{n}" }
    password_confirmation { password }
    active true

    factory :participant do
      sequence(:username) {|n| "test_participant#{n}" }
      group_id { FactoryGirl.create(:group).id }
      role 'participant'
    end

    factory :moderator do
      sequence(:username) {|n| "test_mod#{n}" }
      role 'moderator'
    end

    factory :admin do
      sequence(:username) {|n| "test_admin#{n}" }
      role 'admin'
    end

    factory :spectator do
      sequence(:username) {|n| "test_spectator#{n}" }
      group { FactoryGirl.create(:group) }
      role 'spectator'
    end
  end
end
