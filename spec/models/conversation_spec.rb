require 'spec_helper'

describe Conversation do
  context "validation" do
    before do
      @conversation = Conversation.new
      @conversation.valid?
    end

    it "needs a usera" do
      @conversation.should have(1).error_on(:usera_id)
    end

    it "needs a userb" do
      @conversation.should have(1).error_on(:userb_id)
    end

    it "needs a subject" do
      @conversation.should have(1).error_on(:subject)
    end

    it "subject may not be empty" do
      @conversation.subject = '  '
      @conversation.valid?
      @conversation.should have(1).error_on(:subject)
    end
  end

  context "attributes" do
    before do
      @conversation = Conversation.new
    end

    it "has a usera" do
      @conversation.usera = User.new
    end

    it "has a usera" do
      @conversation.userb = User.new
    end

    it "has a read_by_a defaulting to false" do
      @conversation.read_by_a.should eql false
    end

    it "has a read_by_b defaulting to false" do
      @conversation.read_by_b.should eql false
    end

    it "has messages" do
      @conversation.messages << Message.new
      @conversation.messages.should have(1).item
    end
  end

  context ".between" do
    before do
      @usera = FactoryGirl.create(:moderator)
      @userb = FactoryGirl.create(:moderator)
      @userc = FactoryGirl.create(:moderator)
      FactoryGirl.create :conversation, :usera => @usera, :userb => @userb
      FactoryGirl.create :conversation, :usera => @usera, :userb => @userc
    end

    it "returns a ActiveRecordRelations that gets one conversation object between given two user ids" do
      conversations = Conversation.between(@usera.id, @userb.id)
      conversations.should be_instance_of(ActiveRecord::Relation)
    end

    it "returns list of two conversation object between given two user ids" do
      conversations = Conversation.between(@usera.id, @userb.id).all
      conversations.should have(1).item
    end

    it "and order of parameters does not matter" do
      conversations = Conversation.between(@userb.id, @usera.id)
      conversations.should have(1).item
    end

    it "accepts user intances" do
      conversations = Conversation.between(@usera, @userb)
      conversations.should have(1).item
    end
  end

  context ".of" do
    before do
      @user = FactoryGirl.create(:moderator)
      FactoryGirl.create :conversation, :usera => @user
      FactoryGirl.create :conversation, :userb => @user
    end

    it "returns a list of conversations user_id participated in" do
      conversations = Conversation.of(@user.id)
      conversations.should have(2).items
    end

    it "returns a list of conversations user participated in" do
      conversations = Conversation.of(@user)
      conversations.should have(2).items
    end
  end

  context ".read_by" do
    before do
      @usera = FactoryGirl.create(:moderator)
      @userb = FactoryGirl.create(:moderator)
      @userc = FactoryGirl.create(:moderator)
      @conversation = FactoryGirl.create :conversation, :usera => @usera, :userb => @userb, :read_by_a => true
    end

    it "returns true if read by this user" do
      @conversation.read_by(@usera).should be true
    end

    it "returns false if unread by this user" do
      @conversation.read_by(@userb).should be false
    end

    it "returns false if user is not part of conversation" do
      @conversation.read_by(@userc).should be false
    end
   end
end
