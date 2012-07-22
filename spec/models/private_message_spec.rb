require 'spec_helper'

describe PrivateMessage do
  describe '.conversation scope' do
    before do
      # moderator because we do not want to think about writing rights in this test
      @user1 = FactoryGirl.create(:moderator)
      @user2 = FactoryGirl.create(:moderator)
    end

    context 'if there is no conversation' do
      it 'finds nothing' do
        PrivateMessage.conversation(@user1.id, @user2.id).should be_empty
      end

      it 'in either order of parameters' do
        PrivateMessage.conversation(@user2.id, @user1.id).should be_empty
      end
    end

    context 'if there user 1 recieved a message' do
      before do
        FactoryGirl.create(:private_message, :author => @user2, :recipient => @user1)
      end

      it 'finds one message' do
        PrivateMessage.conversation(@user1.id, @user2.id).should have(1).items
      end

      it 'in either order of parameters' do
        PrivateMessage.conversation(@user1.id, @user2.id).should have(1).items
      end
    end

    context 'if they corresopnded several times' do
      before do
        FactoryGirl.create_list(:private_message, 2, :author => @user2, :recipient => @user1)
        FactoryGirl.create_list(:private_message, 3, :author => @user1, :recipient => @user2)
      end

      it 'finds all five message' do
        PrivateMessage.conversation(@user1.id, @user2.id).should have(5).items
      end

      it 'in either order of parameters' do
        PrivateMessage.conversation(@user1.id, @user2.id).should have(5).items
      end
    end
  end
end
