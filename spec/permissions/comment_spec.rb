require 'spec_helper'
require "cancan/matchers"

describe "Comment Permissions" do
  let(:ability) { Ability.new(user) }
  subject { ability }

  context "no user" do
    let(:user){ nil }

    it { should_not be_able_to(:create, Comment) }
    it { should_not be_able_to(:read, Comment) }
    it { should_not be_able_to(:update, Comment) }
    it { should_not be_able_to(:destroy, Comment) }
  end

  context "admin user" do
    let(:user) { FactoryGirl.create :admin }

    %w[create update].each do |action|
      it { should_not be_able_to(action.to_sym, Comment) }
    end

    it { should be_able_to(:read, Comment) }
    it { should be_able_to(:destroy, Comment) }
  end

  context "moderator user" do
    let(:user) { FactoryGirl.create :moderator }
    let(:own_study) { FactoryGirl.create :study, moderator_id: user.id }
    let(:own_group) { FactoryGirl.create :group, study_id: own_study.id }
    let(:blog) { FactoryGirl.create :blog, group_id: own_group.id }
    let(:another_blog) { FactoryGirl.create :blog }
    let(:blog_entry) { FactoryGirl.create :blog_entry, blog_id: blog.id }
    let(:comment) { FactoryGirl.create :comment, blog_entry_id: blog_entry.id }

    context "in commentable groups" do
      context "in his on studies" do
        it { should be_able_to(:manage, comment) }
      end

      context "in foreign studies" do
        let(:another_blog_entry) { FactoryGirl.create :blog_entry, blog_id: another_blog.id }
        let(:another_comment) { FactoryGirl.create :comment, blog_entry_id: another_blog_entry.id }

        it { should be_able_to(:manage, comment) }
      end
    end

    context "in not commentable groups" do
      before do
        own_group.update_attribute(:are_commentable, false)
      end

      context "in his on studies" do
        it { should_not be_able_to(:manage, comment) }
      end
    end
  end

  context "spectator user" do
    let(:study) { FactoryGirl.create :study }
    let(:user) { FactoryGirl.create :spectator, group_id: own_group.id }
    let(:own_group) { FactoryGirl.create :group, study_id: study.id }
    let(:own_group2) { FactoryGirl.create :group, study_id: study.id }
    let(:blog) { FactoryGirl.create :blog, group_id: own_group2.id }
    let(:another_blog) { FactoryGirl.create :blog }
    let(:blog_entry) { FactoryGirl.create(:blog_entry, blog_id: blog.id) }
    let(:another_blog_entry) { FactoryGirl.create(:blog_entry) }

    context "in commentable groups" do
      context "in a group of his study" do
        %w[create update destroy].each do |action|
          it { should_not be_able_to(action.to_sym, blog_entry.comments.new) }
        end
        it { should be_able_to(:read, blog_entry.comments.new) }
      end

      context "in a group of another study" do
        %w[create read update destroy].each do |action|
          it { should_not be_able_to(action.to_sym, another_blog_entry.comments.new) }
        end
      end
    end

    context "in not commentable groups" do
      before do
        own_group.update_attribute(:are_commentable, false)
      end

      context "in his on studies" do
        it { should_not be_able_to(:manage, blog_entry.comments.new) }
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
    let(:comments) { FactoryGirl.create :comments, blog_entry_id: entry.id }

    context "his own coments" do
      %w[create read update destroy].each do |action|
        it { should be_able_to(action.to_sym, entry) }
      end
    end

    context "in his on group" do
      context "in his own blog" do
        let(:entry) { FactoryGirl.create :blog_entry, blog_id: blog.id }
        let(:own_comment) { FactoryGirl.create :comment, blog_entry_id: entry.id, author_id: user.id }
        let(:another_comment) { FactoryGirl.create :comment, blog_entry_id: entry.id }

        %w[create read update destroy].each do |action|
          it { should be_able_to(action.to_sym, own_comment) }
        end

        it { should be_able_to(:read, another_comment) }
        %w[create update destroy].each do |action|
          it { should_not be_able_to(action.to_sym, another_comment) }
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
      let(:another_blog_entry) { another_blog.entries.new }

      %w[create read update destroy].each do |action|
        it { should_not be_able_to(action.to_sym, another_blog_entry.comments.new) }
      end
    end
  end
end
