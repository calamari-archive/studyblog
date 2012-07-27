require 'spec_helper'

describe ConversationsController do
  before do
    @usera = FactoryGirl.create(:moderator)
    @userb = FactoryGirl.create(:moderator)
    @userc = FactoryGirl.create(:moderator)
  end

  context "if we are logged out" do
    context "#create" do
      it "can not create a Conversation" do
        expect {
          post :create, :conversation => {
            :recipient_id => 1,
            :subject => 'Test',
            :content => '  Content  '
          }
        }.to_not change(Conversation, :count).by(+1)
      end
    end

    context "#reply" do
      before do
        @conversation = FactoryGirl.create(:conversation, :usera => @usera, :userb => @userb)
      end

      context "when POSTing" do
        it "does not add a Message to Conversation" do
          expect {
            post :reply, :id => @conversation.id, :conversation => {
              :content => ' Reply Content  '
            }
          }.to_not change(Message, :count).by(+1)
        end
      end
    end
  end

  context "if we are logged in" do
    before do
      login @usera
    end

    context "#show" do
      let(:conversation) { FactoryGirl.create(:conversation, :usera => @usera, :userb => @userb) }
      before do
        get :show, :id => conversation.id
      end

      it "sends conversation to view" do
        assigns[:conversation].should eql conversation
      end

      it "sends messages to view" do
        assigns[:messages].each_with_index do |m, i|
          m.should eql conversation.messages[i]
        end
      end

      it "sends user (recipient) to view" do
        assigns[:user].should eql @userb
      end
    end

    context "#create" do
      context "does not create a conversation object when" do
        it "userb_id is not given" do
          expect {
            post :create, :conversation => {
              :subject => 'Test',
              :content => 'Content'
            }
          }.to_not change(Conversation, :count).by(+1)
        end

        it "subject is not given" do
          expect {
            post :create, :conversation => {
              :userb_id => 1,
              :content => 'Content'
            }
          }.to_not change(Conversation, :count).by(+1)
        end

        it "subject is empty" do
          expect {
            post :create, :conversation => {
              :userb_id => 1,
              :subject => ' ',
              :content => 'Content'
            }
          }.to_not change(Conversation, :count).by(+1)
        end

        it "content is not given" do
          expect {
            post :create, :conversation => {
              :userb_id => 1,
              :subject => 'Test'
            }
          }.to_not change(Conversation, :count).by(+1)
        end

        it "content is empty" do
          expect {
            post :create, :conversation => {
              :userb_id => 1,
              :subject => 'Test',
              :content => '     '
            }
          }.to_not change(Conversation, :count).by(+1)
        end
      end
    end

    context "if everything is correct" do
      it "creates a Conversation object" do
        expect {
          post :create, :conversation => {
            :userb_id => @userb.id,
            :subject => 'Test',
            :content => '  Content  '
          }
        }.to change(Conversation, :count).by(+1)
      end

      it "creates a Message object" do
        expect {
          post :create, :conversation => {
            :userb_id => @userb.id,
            :subject => 'Test',
            :content => '  Content  '
          }
        }.to change(Message, :count).by(+1)
      end

      it "created Message belongs to created conversation" do
        post :create, :conversation => {
          :userb_id => @userb.id,
          :subject => 'Test',
          :content => '  Content  '
        }
        Message.last.conversation.should eql Conversation.last
      end

      it "redirects to page of recipient" do
        post :create, :conversation => {
          :userb_id => @userb.id,
          :subject => 'Test',
          :content => '  Content  '
        }

        response.should redirect_to user_path(@userb)
      end
    end

    context "#new" do
      context "if given a recipient" do
        before do
          get :new, :user_id => @userb.id
        end

        it "sends a new conversation object to view with userb prefilled" do
          assigns[:conversation].userb_id.should eql @userb.id
        end

        it "sends a new conversation object to view with usera prefilled" do
          assigns[:conversation].usera.should eql @usera
        end

        it "does not populate available_contacts" do
          assigns[:available_contacts].should be_nil
        end

        it "sends recipient to view" do
          assigns[:recipient].should eql @userb
        end

        it "sends new message to view" do
          assigns[:message].should be_new_record
        end

        it "sends messages of conversation to view" do
          assigns[:messages].should be_empty
        end

        it "renders reply view" do
          response.should render_template('new')
        end
      end

      context "without a recipient" do
        before do
          get :new
        end

        it "sends a new conversation object to view with userb prefilled" do
          assigns[:conversation].userb.should be_nil
        end

        it "sends a new conversation object to view with usera prefilled" do
          assigns[:conversation].usera.should eql @usera
        end

        it "does populate available_contacts with a list" do
          assigns[:available_contacts].class.should be Array
        end

        it "does not send recipient to view" do
          assigns[:recipient].should be_nil
        end

        it "sends new message to view" do
          assigns[:message].should be_new_record
        end

        it "sends empty messages of conversation to view" do
          assigns[:messages].should be_empty
        end

        it "renders reply view" do
          response.should render_template('new')
        end
      end
    end

    context "#reply" do
      before do
        @conversation = FactoryGirl.create(:conversation, :usera => @usera, :userb => @userb)
      end

      context "when GETing" do
        before do
          get :reply , :id => @conversation.id
        end

        it "sends conversation to view" do
          assigns[:conversation].should eql @conversation
        end

        it "sends recipient to view" do
          assigns[:recipient].should eql @userb
        end

        it "sends messages of conversation to view" do
          assigns[:messages][0].should eql @conversation.messages[0]
        end

        it "sends a new message to view" do
          assigns[:message].should be_new_record
        end

        it "renders reply view" do
          response.should render_template('new')
        end
      end

      context "when POSTing" do
        context "if everything is ok" do
          it "does create a Message object" do
            expect {
              post :reply, :id => @conversation.id, :conversation => {
                :content => ' Reply Content  '
              }
            }.to change(Message, :count).by(+1)
          end

          it "adds the Message to the Conversation" do
            post :reply, :id => @conversation.id, :conversation => {
              :content => 'Reply Content!'
            }
            conversation = @conversation.reload
            conversation.messages.should have(2).items
          end
        end

        context "if content is missing" do
          it "does not create a Message object" do
            expect {
              post :reply, :id => @conversation.id, :conversation => {
                :content => ''
              }
            }.to_not change(Message, :count).by(+1)
          end
        end

        context "if user is not part of the conversation" do
          before do
            @conversation = FactoryGirl.create(:conversation, :usera => @userc, :userb => @userb)
          end

          it "he can not reply to the conversation" do
            expect {
              post :reply, :id => @conversation.id, :conversation => {
                :content => ''
              }
            }.to_not change(Message, :count).by(+1)
          end
        end
      end
    end
  end
end
