require 'spec_helper'

describe Message do
  context "validation" do
    before do
      @message = Message.new
      @message.valid?
    end

    it "needs a author" do
      @message.should have(1).error_on(:author_id)
    end

    it "needs a content" do
      @message.should have(1).error_on(:content)
    end

    it "needs a conversation" do
      @message.should have(1).error_on(:conversation_id)
    end
  end

  context "attributes" do
    before do
      @message = Message.new
    end

    it "has an author" do
      @message.author = User.new
    end

    it "has a conversation" do
      @message.conversation = Conversation.new
    end
  end
end
