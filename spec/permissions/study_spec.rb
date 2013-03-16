require 'spec_helper'
require "cancan/matchers"

describe "BlogEntry Permissions" do
  let(:ability) { Ability.new(user) }
  subject { ability }

  context "no user" do
    let(:user){ nil }

    it { should_not be_able_to(:create, BlogEntry) }
    it { should_not be_able_to(:read, BlogEntry) }
    it { should_not be_able_to(:update, BlogEntry) }
    it { should_not be_able_to(:destroy, BlogEntry) }
  end

  context "admin user" do
    let(:user) { FactoryGirl.create :admin }

    %w[create read update destroy assign activate].each do |action|
      it { should be_able_to(action.to_sym, Study) }
    end
  end

  context "moderator user" do
    let(:user) { FactoryGirl.create :moderator }
    let(:own_study) { FactoryGirl.create :study, moderator_id: user.id }
    let(:study_of_another_mod) { FactoryGirl.create :study }

    %w[create read update destroy activate].each do |action|
      it { should be_able_to(action.to_sym, own_study) }
    end

    it { should_not be_able_to(:assign, own_study) }

    %w[create read update destroy assign activate].each do |action|
      it { should_not be_able_to(action.to_sym, study_of_another_mod) }
    end
  end

  context "spectator user" do
    let(:user) { FactoryGirl.create :spectator }

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, user.study) }
    end
  end

  context "participant user" do
    let(:user) { FactoryGirl.create :participant }

    %w[create read update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, user.study) }
    end
  end
end
