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

  context ".between scope" do
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

  context ".of scope" do
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

  context ".unread scope" do
    let!(:user1) { FactoryGirl.create(:moderator) }
    let!(:user2) { FactoryGirl.create(:moderator) }
    let!(:user3) { FactoryGirl.create(:moderator) }

    it "returns a ActiveRecordRelations that gets all conversations given user has not read all messages from" do
      conversations = Conversation.unread(user1)
      conversations.should be_instance_of(ActiveRecord::Relation)
    end

    context "with no conversations in the system" do
      it "results in empty list for user1" do
        Conversation.unread(user1).should be_empty
      end

      it "results in empty list for user2" do
        Conversation.unread(user2).should be_empty
      end
    end

    context "with only read conversations of user1" do
      let!(:conversation)  { FactoryGirl.create(:conversation, :usera => user1, :userb => user2, :read_by_a => true) }
      let!(:conversation2) { FactoryGirl.create(:conversation, :usera => user3, :userb => user1, :read_by_b => true) }

      it "results in empty list for user1" do
        Conversation.unread(user1).should be_empty
      end

      it "find one item for user2" do
        Conversation.unread(user2).should have(1).item
      end

      it "find one item for user3" do
        Conversation.unread(user3).should have(1).item
      end

      it "finds the right conversation for user2" do
        Conversation.unread(user2).map(&:id).should include(conversation.id)
      end

      it "finds the right conversation for user3" do
        Conversation.unread(user3).map(&:id).should include(conversation2.id)
      end
    end

    context "with unread conversations of all users" do
      let!(:conversation)  { FactoryGirl.create(:conversation, :usera => user1, :userb => user2) }
      let!(:conversation2) { FactoryGirl.create(:conversation, :usera => user1, :userb => user3) }

      it "results in two items for user1" do
        Conversation.unread(user1).should have(2).items
      end

      it "find one item for user2" do
        Conversation.unread(user2).should have(1).item
      end

      it "find one item for user3" do
        Conversation.unread(user3).should have(1).item
      end
    end
  end

  context ".read_by?" do
    before do
      @usera = FactoryGirl.create(:moderator)
      @userb = FactoryGirl.create(:moderator)
      @userc = FactoryGirl.create(:moderator)
      @conversation = FactoryGirl.create :conversation, :usera => @usera, :userb => @userb, :read_by_a => true
    end

    it "returns true if read by this user" do
      @conversation.read_by?(@usera).should be true
    end

    it "returns false if unread by this user" do
      @conversation.read_by?(@userb).should be false
    end

    it "returns false if user is not part of conversation" do
      @conversation.read_by?(@userc).should be false
    end
  end

  context ".read_by!" do
    before do
      @usera = FactoryGirl.create(:moderator)
      @userb = FactoryGirl.create(:moderator)
      @userc = FactoryGirl.create(:moderator)
      @conversation = FactoryGirl.create :conversation, :usera => @usera, :userb => @userb
    end

    it "usera set read_by_a to true" do
      @conversation.read_by!(@usera)
      @conversation.read_by_a.should be true
      @conversation.read_by_b.should be false
    end

    it "userb set read_by_b to true" do
      @conversation.read_by!(@userb)
      @conversation.read_by_a.should be false
      @conversation.read_by_b.should be true
    end

    it "set with not participating user does nothing" do
      @conversation.read_by!(@userc)
      @conversation.read_by_a.should be false
      @conversation.read_by_b.should be false
    end
  end

  context ".unread_by!" do
    before do
      @usera = FactoryGirl.create(:moderator)
      @userb = FactoryGirl.create(:moderator)
      @userc = FactoryGirl.create(:moderator)
      @conversation = FactoryGirl.create :conversation, :usera => @usera, :userb => @userb, :read_by_a => true, :read_by_b => true
    end

    it "usera set read_by_a to false" do
      @conversation.unread_by!(@usera)
      @conversation.read_by_a.should be false
      @conversation.read_by_b.should be true
    end

    it "userb set read_by_b to false" do
      @conversation.unread_by!(@userb)
      @conversation.read_by_a.should be true
      @conversation.read_by_b.should be false
    end

    it "set with not participating user does nothing" do
      @conversation.unread_by!(@userc)
      @conversation.read_by_a.should be true
      @conversation.read_by_b.should be true
    end
  end

  context ".the_other_user" do
    let(:conversation) { FactoryGirl.create(:conversation) }

    it "returns usera if userb is given" do
      conversation.the_other_user(conversation.userb).should eql conversation.usera
    end

    it "returns userb if usera is given" do
      conversation.the_other_user(conversation.usera).should eql conversation.userb
    end
  end

  context ".has_written_something" do
    let!(:usera) { FactoryGirl.create(:moderator) }
    let!(:userb) { FactoryGirl.create(:moderator) }
    let!(:conversation) { FactoryGirl.create(:conversation, :usera => usera, :userb => userb) }

    context "only usera wrote to userb" do
      let!(:message1) { FactoryGirl.create(:message, :conversation => conversation, :author => usera) }
      let!(:message2) { FactoryGirl.create(:message, :conversation => conversation, :author => usera) }

      it "returns true for user usera" do
        conversation.has_written_something(usera).should be true
      end

      it "returns false for user userb" do
        conversation.has_written_something(userb).should be false
      end
    end

    context "both users participated" do
      let!(:message1) { FactoryGirl.create(:message, :conversation => conversation, :author => usera) }
      let!(:message2) { FactoryGirl.create(:message, :conversation => conversation, :author => userb) }

      it "returns true for user usera" do
        conversation.has_written_something(usera).should be true
      end

      it "returns true for user userb" do
        conversation.has_written_something(userb).should be true
      end
    end
  end
end
