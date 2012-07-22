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
      @usera = FactoryGirl.create(:user)
      @userb = FactoryGirl.create(:user)
      @userc = FactoryGirl.create(:user)
      FactoryGirl.create :conversation, :usera => @usera, :userb => @userb
    end

    it "returns a conversation object between given two user ids" do
      conversation = Conversation.between(@usera.id, @userb.id)
      conversation.should be_instance_of(Conversation)
    end

    it "and order does not matter" do
      conversation = Conversation.between(@userb.id, @usera.id)
      conversation.should be_instance_of(Conversation)
    end

    it "accepts user intances" do
      conversation = Conversation.between(@usera, @userb)
      conversation.should be_instance_of(Conversation)
    end

    context "if it does not exist" do
      before do
        @conversation = Conversation.between(@usera, @userc)
      end

      it "creates Conversation " do
        @conversation.should be_new_record
      end

      it "created conversation has first given user as usera" do
        @conversation.usera.should eql @usera
      end

      it "created conversation has second given user as userb" do
        @conversation.userb.should eql @userc
      end

      it "creates Conversation although changed order" do
        conversation = Conversation.between(@userc, @userb)
        conversation.should be_new_record
      end
    end
  end

  context ".of" do
    before do
      @user = FactoryGirl.create(:user)
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
end
