require 'spec_helper'
require "cancan/matchers"

describe "Group Permissions" do
  let(:ability) { Ability.new(user) }
  subject { ability }

  context "no user" do
    let(:user){ nil }

    it { should_not be_able_to(:create, Group) }
    it { should_not be_able_to(:read, Group) }
    it { should_not be_able_to(:update, Group) }
    it { should_not be_able_to(:destroy, Group) }
  end

  context "admin user" do
    let(:user) { FactoryGirl.create :admin }

    %w[create read update destroy].each do |action|
      it { should be_able_to(action.to_sym, Group) }
    end
  end

  context "moderator user" do
    let(:user) { FactoryGirl.create :moderator }
    let(:own_study) { FactoryGirl.create :study, moderator_id: user.id }
    let(:study_of_another_mod) { FactoryGirl.create :study }
    let(:own_group) { FactoryGirl.create :group, study_id: own_study.id }
    let(:group_of_another_mod) { FactoryGirl.create :group, study_id: study_of_another_mod.id }

    %w[create read update destroy].each do |action|
      it { should be_able_to(action.to_sym, own_group) }
    end

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, group_of_another_mod) }
    end
  end

  context "spectator user" do
    let(:user) { FactoryGirl.create :spectator }

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, Group) }
    end
  end

  context "participant user" do
    let(:user) { FactoryGirl.create :participant }

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, Group) }
    end
  end
end
