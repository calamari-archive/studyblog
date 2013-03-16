require 'spec_helper'
require "cancan/matchers"

describe "Blog Permissions" do
  let(:ability) { Ability.new(user) }
  subject { ability }

  context "no user" do
    let(:user){ nil }

    it { should_not be_able_to(:create, Blog) }
    it { should_not be_able_to(:read, Blog) }
    it { should_not be_able_to(:update, Blog) }
    it { should_not be_able_to(:destroy, Blog) }
  end

  context "admin user" do
    let(:user) { FactoryGirl.create :admin }

    %w[create update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, Blog) }
    end

    it { should be_able_to(:read, Blog) }
  end

  context "moderator user" do
    let(:user) { FactoryGirl.create :moderator }
    let(:own_study) { FactoryGirl.create :study, moderator_id: user.id }
    let(:own_group) { FactoryGirl.create :group, study_id: own_study.id }
    let(:blog) { FactoryGirl.create :blog, group_id: own_group.id }
    let(:another_blog) { FactoryGirl.create :blog }

    %w[create update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, Blog) }
    end

    it { should be_able_to(:read, blog) }
    it { should_not be_able_to(:read, another_blog) }
  end

  context "spectator user" do
    let(:user) { FactoryGirl.create :spectator }
    let(:own_group) { FactoryGirl.create :group, study_id: user.study.id }
    let(:blog) { FactoryGirl.create :blog, group_id: own_group.id }
    let(:another_blog) { FactoryGirl.create :blog }

    %w[create update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, Blog) }
    end

    it { should be_able_to(:read, blog) }
    it { should_not be_able_to(:read, another_blog) }
  end

  context "participant user" do
    let(:user) { FactoryGirl.create :participant}
    let(:blog) { FactoryGirl.create :blog, group_id: user.group.id }
    let(:another_blog) { FactoryGirl.create :blog }

    %w[create update destroy].each do |action|
      it { should_not be_able_to(action.to_sym, Blog) }
    end

    context "in a group where participants can see each other" do
      it { should be_able_to(:read, blog) }
      it { should_not be_able_to(:read, another_blog) }
    end

    context "in a group where participants can see each other" do
      before do
        user.group.can_user_see_eachother = false
        user.group.save!
      end

      it { should_not be_able_to(:read, blog) }
      it { should_not be_able_to(:read, another_blog) }
    end
  end
end
