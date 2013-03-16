require 'spec_helper'

describe UsersController do
  context "Permissions" do
    all_actions = %w{show index new create update destroy manage_participants manage_spectators deactivate reactivate profile}

    let(:participant) { FactoryGirl.create(:participant) }
    let(:moderator) { FactoryGirl.create(:moderator) }
    let(:admin) { FactoryGirl.create(:admin) }

    context "if user is logged out" do
      all_actions.each do |action|
        it "can't reach participant users##{action}" do
          get action.to_sym, :id => participant.id
          should_access_deny(response)
        end

        it "can't reach moderator users##{action}" do
          get action.to_sym, :id => moderator.id
          should_access_deny(response)
        end

        it "can't reach admin users##{action}" do
          get action.to_sym, :id => admin.id
          should_access_deny(response)
        end
      end
    end
  end


  context "if we are logged in" do
    let(:current_user) { FactoryGirl.create(:moderator) }

    before do
      login @current_user
    end

    context "#index" do
      #TODO
    end

    context "#show" do
      # users
      let(:moderator) { FactoryGirl.create(:moderator) }
      let(:participant) { FactoryGirl.create(:participant) }
      let(:spectator) { FactoryGirl.create(:spectator) }
      # conversations
      let!(:conversation1) { FactoryGirl.create(:conversation, :usera => current_user, :userb => participant) }
      let!(:conversation2) { FactoryGirl.create(:conversation, :usera => moderator, :userb => current_user) }

      context "if looking at a moderator" do
        before do
          get :show, :id => moderator.id
        end

        it "sends user we look at to view" do
          assigns[:user].should eql moderator
        end

        it "sends a list of conversations with the moderator to view" do
          assigns[:conversations].should include(conversation2)
        end
      end

      context "if looking at a participant" do
        before do
          get :show, :id => participant.id
        end

        it "sends user we look at to view" do
          assigns[:user].should eql participant
        end

        it "sends group of participant to view" do
          assigns[:group].should eql participant.group
        end

        it "sends a list of conversations with the participant to view" do
          assigns[:conversations].should include(conversation1)
        end
      end

      context "if looking at a spectator as moderator" do
        before do
          get :show, :id => spectator.id
        end

        it "shows the profile page" do
          response.should render_template('show')
        end
      end

      context "if looking at a spectator as participant" do
        before do
          login participant
          get :show, :id => spectator.id
        end

        it "does redirect instead of showing the profile page" do
          response.should redirect_to(root_url)
        end
      end
    end

    #TODO new, new_spectator, create_spectator, destroy_spectator,
    #     new_participant, create_participant, destroy_participant, edit, create, update
    #     deactivate, reactivate, setup, profile
  end
end
