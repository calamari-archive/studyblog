require 'spec_helper'
require "cancan/matchers"

describe "User Permissions" do
  let(:ability) { Ability.new(user) }
  subject { ability }
  let(:mod) { FactoryGirl.create :moderator }
  let(:admin) { FactoryGirl.create :admin }

  context "no user" do
    let(:user){ nil }

    it { should_not be_able_to(:create, User) }
    it { should_not be_able_to(:read, User) }
    it { should_not be_able_to(:update, User) }
    it { should_not be_able_to(:destroy, User) }
  end

  context "admin user" do
    let(:user) { FactoryGirl.create :admin }

    %w[create read update destroy new_participant create_participant
       destroy_participant new_spectator create_spectator destroy_spectator
       deactivate reactivate].each do |action|
      it { should be_able_to(action.to_sym, User) }
    end
  end

  context "moderator user" do
    let(:study) { FactoryGirl.create :study, :moderator_id => user.id }
    let(:group) { FactoryGirl.create :group, study_id: study.id }
    let(:group2) { FactoryGirl.create :group, study_id: study.id }
    let(:another_study) { FactoryGirl.create :study }
    let(:another_group) { FactoryGirl.create :group, study_id: another_study.id }
    let(:participant_in_own_study) { FactoryGirl.create :participant, group_id: group.id }
    let(:participant_in_own_study2) { FactoryGirl.create :participant, group_id: group2.id }
    let(:participant_in_other_study) { FactoryGirl.create :participant, group_id: another_group.id }

    let(:user) { FactoryGirl.create :moderator }
    let(:another_mod) { FactoryGirl.create :moderator }

    %w[create destroy deactivate reactivate].each do |action|
      it { should_not be_able_to(action.to_sym, User) }
    end

    %w[new_spectator create_spectator destroy_spectator
       new_participant create_participant destroy_participant].each do |action|
      it { should be_able_to(action.to_sym, User) }
    end

    it { should be_able_to(:read, user) }
    it { should be_able_to(:update, user) }

    it { should be_able_to(:read, participant_in_own_study) }
    it { should be_able_to(:read, participant_in_own_study2) }
    it { should_not be_able_to(:update, participant_in_own_study) }
    it { should_not be_able_to(:update, participant_in_own_study2) }

    it { should_not be_able_to(:read, participant_in_other_study) }
    it { should_not be_able_to(:read, another_mod) }
    it { should be_able_to(:read, admin) }
  end

  context "spectator user" do
    let(:study) { FactoryGirl.create :study }
    let(:group) { FactoryGirl.create :group, study_id: study.id }
    let(:user) { FactoryGirl.create :spectator, group_id: group.id }
    let(:participant_in_study) { FactoryGirl.create :participant, group_id: group.id }
    let(:participant_in_another_study) { FactoryGirl.create :participant }
    let(:another_spectator) { FactoryGirl.create :spectator, group_id: group.id }

    %w[create destroy new_participant create_participant
       destroy_participant new_spectator create_spectator destroy_spectator
       deactivate reactivate].each do |action|
      it { should_not be_able_to(action.to_sym, User) }
    end

    it { should be_able_to(:read, user) }
    it { should be_able_to(:update, user) }

    it { should be_able_to(:read, participant_in_study) }
    it { should_not be_able_to(:update, participant_in_study) }

    it { should_not be_able_to(:read, participant_in_another_study) }
    it { should_not be_able_to(:update, participant_in_another_study) }

    it { should_not be_able_to(:read, another_spectator) }
    it { should_not be_able_to(:update, another_spectator) }
    it { should_not be_able_to(:read, admin) }
  end

  context "participant user" do
    let(:group) { FactoryGirl.create :group }
    let(:user) { FactoryGirl.create :participant, group_id: group.id }
    let(:another_user_same_group) { FactoryGirl.create :participant, group_id: group.id }
    let(:another_user_different_group) { FactoryGirl.create :participant }
    let(:spectator) { FactoryGirl.create :spectator, group_id: group.id }

    %w[create destroy new_participant create_participant
       destroy_participant new_spectator create_spectator destroy_spectator
       deactivate reactivate].each do |action|
      it { should_not be_able_to(action.to_sym, User) }
    end

    context "in a group where participants can see each other" do
      it { should be_able_to(:read, user) }
      it { should be_able_to(:update, user) }

      it { should be_able_to(:read, another_user_same_group) }
      it { should_not be_able_to(:update, another_user_same_group) }

      it { should_not be_able_to(:read, another_user_different_group) }
      it { should_not be_able_to(:update, another_user_different_group) }

      it { should_not be_able_to(:read, spectator) }
      it { should_not be_able_to(:update, spectator) }
      it { should_not be_able_to(:read, admin) }
    end

    context "in a group where participants cannot see each other" do
      let(:group) { FactoryGirl.create :group, can_user_see_eachother: false }

      it { should be_able_to(:read, user) }
      it { should be_able_to(:update, user) }

      it { should_not be_able_to(:read, another_user_same_group) }
      it { should_not be_able_to(:update, another_user_same_group) }

      it { should_not be_able_to(:read, another_user_different_group) }
      it { should_not be_able_to(:update, another_user_different_group) }

      it { should_not be_able_to(:read, spectator) }
      it { should_not be_able_to(:update, spectator) }
      it { should_not be_able_to(:read, admin) }
    end
  end
end
