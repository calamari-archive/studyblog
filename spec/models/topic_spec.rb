require 'spec_helper'

describe Topic do
  context "validation" do
    context "given empty topic" do
      let(:topic) { Topic.new }
      before do
        topic.valid?
      end

      it "fails with title" do
        topic.errors[:title].should_not be_empty
      end

      it "fails not with description" do
        topic.errors[:description].should be_empty
      end

      it "fails with group" do
        topic.errors[:group].should_not be_empty
      end
    end

    context "a topic with closed group" do
      let(:group) { FactoryGirl.create(:group) }
      let(:topic) { FactoryGirl.build(:topic, :group => group) }

      before do
        Study.any_instance.stub(:has_ended?).and_return(true)
        topic.valid?
      end

      it "fails with error in study" do
        p topic.group
        p topic.study
        p topic.study.has_ended?
        topic.errors[:study].should_not be_empty
      end

      it "fails with error in study" do
        topic.errors[:study].first.should eql I18n.t('topics.errors.study_ended')
      end

    end

    context "a fully filled topic" do
      let(:topic) { FactoryGirl.build(:topic) }

      it "passes" do
        topic.should be_valid
      end
    end
  end
end
