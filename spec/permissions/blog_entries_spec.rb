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

    %w[create update].each do |action|
      it { should_not be_able_to(action.to_sym, BlogEntry) }
    end

    it { should be_able_to(:read, BlogEntry) }
    it { should be_able_to(:destroy, BlogEntry) }
  end

  context "moderator user" do
    let(:user) { FactoryGirl.create :moderator }
    let(:own_study) { FactoryGirl.create :study, moderator_id: user.id }
    let(:own_group) { FactoryGirl.create :group, study_id: own_study.id }
    let(:blog) { FactoryGirl.create :blog, group_id: own_group.id }
    let(:another_blog) { FactoryGirl.create :blog }

    %w[create update].each do |action|
      it { should_not be_able_to(action.to_sym, BlogEntry) }
    end

    context "in his on studies" do
      let(:blog_entry) { FactoryGirl.create :blog_entry, blog_id: blog.id }

      it { should be_able_to(:read, blog_entry) }
      it { should be_able_to(:destroy, blog_entry) }
    end

    context "in foreign studies" do
      let(:another_blog_entry) { FactoryGirl.create :blog_entry, blog_id: another_blog.id }

      it { should_not be_able_to(:read, another_blog_entry) }
      it { should_not be_able_to(:destroy, another_blog_entry) }
    end
  end

  context "spectator user" do
    let(:study) { FactoryGirl.create :study }
    let(:user) { FactoryGirl.create :spectator, group_id: own_group.id }
    let(:own_group) { FactoryGirl.create :group, study_id: study.id }
    let(:own_group2) { FactoryGirl.create :group, study_id: study.id }
    let(:blog) { FactoryGirl.create :blog, group_id: own_group2.id }
    let(:another_blog) { FactoryGirl.create :blog }

    context "in a group of his study" do
      %w[create update destroy].each do |action|
        it { should_not be_able_to(action.to_sym, blog.entries.new) }
      end
      it { should be_able_to(:read, FactoryGirl.create(:blog_entry, blog_id: blog.id)) }
    end

    context "in a group of another study" do
      %w[create read update destroy].each do |action|
        it { should_not be_able_to(action.to_sym, another_blog.entries.new) }
      end
    end
  end

  context "participant user" do
    let(:study) { FactoryGirl.create :study }
    let(:own_group) { FactoryGirl.create :group, study_id: study.id }
    let(:user) { FactoryGirl.create :participant, group_id: own_group.id }
    let(:blog) { FactoryGirl.create :blog, group_id: own_group.id, user_id: user.id }
    let(:another_blog_in_group) { FactoryGirl.create :blog, group_id: own_group.id }
    let(:another_blog) { FactoryGirl.create :blog }
    let(:entry) { FactoryGirl.create :blog_entry, blog_id: blog.id }

    context "his own entries" do
      %w[create read update destroy].each do |action|
        it { should be_able_to(action.to_sym, entry) }
      end
    end

    context "in his on group" do
# TODO Groupblogs
      context "in his own blog" do
        %w[create read update destroy].each do |action|
          it { should be_able_to(action.to_sym, blog.entries.new) }
        end
      end

      context "in another blog" do
        context "when group.can_user_see_eachother is true" do
          %w[create update destroy].each do |action|
            it { should_not be_able_to(action.to_sym, another_blog_in_group.entries.new) }
          end
          it { should be_able_to(:read, FactoryGirl.create(:blog_entry, blog_id: another_blog_in_group.id)) }
        end

        context "when group.can_user_see_eachother is false" do
          before do
            own_group.update_attribute(:can_user_see_eachother, false)
          end

          %w[create read update destroy].each do |action|
            it { should_not be_able_to(action.to_sym, another_blog_in_group.entries.new) }
          end
        end
      end
    end
    context "in a different group" do
      %w[create read update destroy].each do |action|
        it { should_not be_able_to(action.to_sym, another_blog.entries.new) }
      end
    end
  end
end
