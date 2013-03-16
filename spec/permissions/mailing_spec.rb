require 'spec_helper'
require "cancan/matchers"

describe "Mailing Permissions" do
  let(:ability) { Ability.new(user) }
  subject { ability }

  context "no user" do
    let(:user){ nil }

    it { should_not be_able_to(:create, Mailing) }
    it { should_not be_able_to(:read, Mailing) }
    it { should_not be_able_to(:update, Mailing) }
    it { should_not be_able_to(:destroy, Mailing) }
  end

  context "admin user" do
    let(:user) { FactoryGirl.create :admin }

    %w[create read update destroy].each do |action|
      it { should be_able_to(action.to_sym, Mailing) }
    end
  end

  context "moderator user" do
    let(:user) { FactoryGirl.create :moderator }
    let(:own_study) { FactoryGirl.create :study, moderator_id: user.id }
    let(:study_of_another_mod) { FactoryGirl.create :study }
    let(:own_mailing) { FactoryGirl.create :mailing, study_id: own_study.id }
    let(:mailing_of_another_mod) { FactoryGirl.create :mailing, study_id: study_of_another_mod.id }

    %w[create read update destroy].each do |action|
      it { should be_able_to(action.to_sym, own_mailing) }
    end

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, mailing_of_another_mod) }
    end
  end

  context "spectator user" do
    let(:user) { FactoryGirl.create :spectator }

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, Mailing) }
    end
  end

  context "participant user" do
    let(:user) { FactoryGirl.create :participant }

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, Mailing) }
    end
  end
end
