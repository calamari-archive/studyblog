require 'spec_helper'
require "cancan/matchers"

describe "Conversation Permissions" do
  let(:ability){ Ability.new(user) }
  subject { ability }
  let(:user2){ FactoryGirl.create :moderator }
  let(:user3){ FactoryGirl.create :moderator }
  let(:my_conversation){ FactoryGirl.create :conversation, :usera_id => user.id, :userb_id => user2.id }
  let(:my_conversation2){ FactoryGirl.create :conversation, :usera_id => user2.id, :userb_id => user.id }
  let(:other_conversation){ FactoryGirl.create :conversation, :usera_id => user2.id, :userb_id => user3.id }

  context "no user" do
    let(:user){ nil }

    it { should_not be_able_to(:manage, Conversation) }
  end

  User::ROLES.each do |role|
    context "#{role} user" do
      let(:user){ FactoryGirl.create role.to_sym }

      it { should be_able_to(:create, Conversation) }

      it { should be_able_to(:read, my_conversation) }
      it { should be_able_to(:read, my_conversation) }
      it { should_not be_able_to(:read, other_conversation) }

      it { should be_able_to(:update, my_conversation) }
      it { should be_able_to(:update, my_conversation) }
      it { should_not be_able_to(:update, other_conversation) }

      it { should be_able_to(:reply, my_conversation) }
      it { should be_able_to(:reply, my_conversation) }
      it { should_not be_able_to(:reply, other_conversation) }

      it { should_not be_able_to(:delete, my_conversation) }
      it { should_not be_able_to(:delete, my_conversation) }
      it { should_not be_able_to(:delete, other_conversation) }
    end
  end
end
