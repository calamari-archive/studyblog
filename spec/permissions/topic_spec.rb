require 'spec_helper'
require "cancan/matchers"

describe "Topic Permissions" do
  let(:ability) { Ability.new(user) }
  subject { ability }

  context "no user" do
    let(:user){ nil }

    it { should_not be_able_to(:create, Topic) }
    it { should_not be_able_to(:read, Topic) }
    it { should_not be_able_to(:update, Topic) }
    it { should_not be_able_to(:destroy, Topic) }
  end

  context "admin user" do
    let(:user) { FactoryGirl.create :admin }
    let(:topic_of_another_mod) { FactoryGirl.create :topic }

    %w[create read update destroy].each do |action|
      it { should be_able_to(action.to_sym, Topic) }
    end

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, topic_of_another_mod) }
    end
  end

  context "moderator user" do
    let(:user) { FactoryGirl.create :moderator }
    let(:own_study) { FactoryGirl.create :study, moderator_id: user.id }
    let(:study_of_another_mod) { FactoryGirl.create :study }
    let(:own_group) { FactoryGirl.create :group, study_id: own_study.id }
    let(:group_of_another_mod) { FactoryGirl.create :group, study_id: study_of_another_mod.id }
    let(:own_topic) { FactoryGirl.create :topic, group_id: own_group.id }
    let(:topic_of_another_mod) { FactoryGirl.create :topic, group_id: group_of_another_mod.id }

    %w[create read update destroy].each do |action|
      it { should be_able_to(action.to_sym, own_topic) }
    end

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, topic_of_another_mod) }
    end
  end

  context "spectator user" do
    let(:user) { FactoryGirl.create :spectator }

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, Topic) }
    end
  end

  context "participant user" do
    let(:user) { FactoryGirl.create :participant }

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, Topic) }
    end
  end
end
